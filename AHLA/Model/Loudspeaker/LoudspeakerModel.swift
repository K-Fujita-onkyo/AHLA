///
///
///Project name: AdHocLoudspeakerArray
/// Class name: LoudspeakerModel
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2024/06/08
///
///
/// ---Explanation---
/// Loudspeaker model
///
///

import SwiftUI
import Foundation
import AVFoundation
import NearbyInteraction
import MultipeerConnectivity

class LoudspeakerModel: AdHocModel, ObservableObject {
    @Published var isConnected: String = "Not connected."
    @Published var isStartNISession: String = "Stop NI Session"
    @Published var loudnessValue: Float  = 1.0
    
    @Published var information: LoudspeakerInfoMessage = LoudspeakerInfoMessage(isConvexHull: false, location: simd_float3(x: 0, y: 0, z: 0))
    
    var innerRoom: InnerRoomInfoMessage = InnerRoomInfoMessage(locations: [])
    var outerRoom: OuterRoomInfoMessage = OuterRoomInfoMessage(width: 5, height: 5, wallCoefficient: 0.05)
    
    let audioPathCalculator: AudioPathModel = AudioPathModel()
    
    @Published var audioEngine: AVAudioEngine = AVAudioEngine()
    var mainMixerNode: AVAudioMixerNode = AVAudioMixerNode()
    let audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!
    let audioStreamer: AudioStreamerModel = AudioStreamerModel()
    var audioQueue: [AudioInfoMessage] = []
    var audioQueue64: [[Float]] = []
    var audioLocation: simd_float3 = simd_float3(x: -5, y: 0, z: 10)
    var nodeMaxNum: Int = 2
    
    var nanoSecondOf1Sample: Double = 1451247.165533
    var sumNanoSecond: Double = 0.0
    var test: Int = 1
    var testBool: Bool = true
    var audioBool: Bool = false
    
    @Published var debugText: String = ""
    
    override init(){
        super.init()
        self.setupNearbyInteraction()
        self.setupAudioPlayer()
        self.playAudio()
        audioStreamer.assignAudioToBuffer(audioFloatArray: audioStreamer.audioFloatArray)
        while let audioInfo:AudioInfoMessage = audioStreamer.getAudioInfoMessage(){
            self.audioQueue.append(audioInfo)
        }
    }
    
    func update(){
        test += 1
        //self.testText = String(test)
    }
    
    func updateLoudspeakerLocation(nearbyObject: NINearbyObject){
        
        let niDiscoveryToken: NIDiscoveryToken = nearbyObject.discoveryToken
        let distance: Float! = nearbyObject.distance
        let direction: simd_float3! = nearbyObject.direction
        
        
        if  distance == nil || direction == nil {
            self.debugText = "Debug(soModel): Can't measure the location of \(niDiscoveryToken)"
            return
        }
        
        //        testText = "OK"
        // FIXME: - This is for simulator values. Please deleted in a real test.
        self.information.location = simd_float3(x: -direction.x*distance, y: direction.y*distance, z: -direction.z*distance)
    }
    
    // MARK: - NISessionDelegate Methods
    
    // Session to to detect movement of other devices
    // Notifies me when the session updates nearby objects.
    override func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
    }
    
    func sessionSuspensionEnd(_ session: NISession) {
        session.run(session.configuration!)
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        self.debugText = String(error.localizedDescription)
    }
    // MARK: - MCSessionDelegate Methods
    
    // Session to change my state
    // Called when the state of a nearby peer changes.
    // State: connected, notConnected, and connecting
    
    override func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case .connected:
            print("Connected")
            self.isConnected = "Connected!!"
            //            self.sendData(data: self.myDiscoveryTokenData, mcPeerID: peerID)
        case .connecting:
            print("Connecting")
            self.isConnected = "Connecting..."
        case .notConnected:
            print("Not connected")
            self.isConnected = "Not connected."
        default:
            print("Other")
        }
    }
    
    // Session to get data
    // Indicates that an NSData object has been received from a nearby peer.
    override func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let loudspeakerInfo = self.convertDataToInstance(type: LoudspeakerInfoMessage.self, data: data){
            self.information = loudspeakerInfo
            self.debugText = "loudspeakerInfo"
            return
        }
        
        if let audioInfo = self.convertDataToInstance(type: AudioInfoMessage.self, data: data){
            let splitAudioInfos = split(array: audioInfo.buffer, size: 64)
            for splitAudioArray in splitAudioInfos {
                let splitAudioInfo = AudioInfoMessage(buffer: splitAudioArray)
                self.audioQueue.append(splitAudioInfo)
            }
            self.debugText = "audioInfo"
            return
        }
        
        if let audioLocationInfo = self.convertDataToInstance(type: AudioLocationInfoMessage.self, data: data){
            self.audioLocation = audioLocationInfo.location
            self.debugText = "audioLocationInfo"
            return
        }
        
        
        if let outerRoomInfo = self.convertDataToInstance(type: OuterRoomInfoMessage.self, data: data){
            self.outerRoom = outerRoomInfo
            
            self.debugText = "outerRoom"
            return
        }
        
        if let innerRoomInfo = self.convertDataToInstance(type: InnerRoomInfoMessage.self, data: data){
            self.innerRoom = innerRoomInfo
            self.debugText = "innerRoom"
            return
        }
        
        if  let niDiscoveryToken = self.startNISession(niDiscoveryTokenData: data){
            self.sendData(data: self.myDiscoveryTokenData, mcPeerID: peerID)
            self.isStartNISession = "StartNISession"
            self.information.isConvexHull = true
            self.debugText = "niSession"
            return
        }
    }
    
    func setupAudioPlayer(){
        self.audioEngine.attach(self.audioPlayerNode)
        self.audioEngine.connect(self.audioPlayerNode, to: self.audioEngine.mainMixerNode, format: self.format)
        self.mainMixerNode = self.audioEngine.mainMixerNode
    }
    
    func playAudio(){
        do {
            try self.audioEngine.start()
            self.audioPlayerNode.play()
        } catch let error {
            print(error)
        }
    }
    
    func playAudioFromFloatArray(floatArray: [Float]) {
        
        let buffer = AVAudioPCMBuffer(pcmFormat: self.format, frameCapacity: AVAudioFrameCount(floatArray.count))!
        buffer.frameLength = AVAudioFrameCount(floatArray.count)
        let audioBuffer = buffer.floatChannelData![0]
        for i in 0..<floatArray.count {
            audioBuffer[i] = floatArray[i]
        }
        self.audioPlayerNode.scheduleBuffer(buffer) {
        }
    }
    
    func split(array: [Float], size: Int) -> [[Float]] {
            guard size > 0 else { return [] }
            return stride(from: 0, to: array.count, by: size).map { startIndex in
                Array(array[startIndex..<min(startIndex + size, array.count)])
            }
    }
    
    func spatializeAudioInRealTime(){
        let start = DispatchTime.now()
        if self.audioQueue.isEmpty {
            return
        }

        self.sumNanoSecond -= 500_000
        if self.testBool == false {
            if self.sumNanoSecond <= self.nanoSecondOf1Sample * 3 {
                self.testBool = true
            } else {
                return
            }
        }
        if self.sumNanoSecond > self.nanoSecondOf1Sample * 3 {
            self.testBool = false
            return
        }
        
        let audioInfo = self.audioQueue.removeFirst()
        
        let audioPath = self.audioPathCalculator.calcAudioPath(
            audioFloatArray: audioInfo.buffer,
            audioLocation: self.audioLocation,
            loudspeakerLocation: self.information.location,
            innerRoom: self.innerRoom,
            outerRoom: self.outerRoom
        )
        
        self.playAudioFromFloatArray(floatArray: audioPath)
        self.test+=1
        
        let end = DispatchTime.now()
        self.sumNanoSecond += self.nanoSecondOf1Sample - Double(end.uptimeNanoseconds - start.uptimeNanoseconds)
    }
    
    func applyLoudness(value: Float){
        self.loudnessValue = round(self.loudnessValue*100 + value )/100
        self.adjustSPL(spl: self.loudnessValue)
    }
    
    func adjustSPL(spl: Float) {
        self.mainMixerNode.outputVolume = spl
    }
}

