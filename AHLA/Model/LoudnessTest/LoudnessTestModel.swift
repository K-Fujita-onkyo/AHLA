import AVFoundation
import SwiftUI
import Foundation
import AVFoundation
import NearbyInteraction
import MultipeerConnectivity

class LoudnessTestModel: ObservableObject{
    var audioEngine: AVAudioEngine
    var audioPlayerNode: AVAudioPlayerNode
    var mainMixerNode: AVAudioMixerNode
    var audioFile: AVAudioFile?
    @Published var spl: Float = 1.00

    init() {
        self.audioEngine = AVAudioEngine()
        self.audioPlayerNode = AVAudioPlayerNode()
        self.mainMixerNode = self.audioEngine.mainMixerNode
        self.audioEngine.attach(self.audioPlayerNode)
        self.loadAudioFile(fileName: "splTest", fileExtension: "wav")
    }
        
    func loadAudioFile(fileName: String, fileExtension: String) {
        guard let audioFileURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Error: audio file not found.")
            return
        }
            
        do {
            self.audioFile = try AVAudioFile(forReading: audioFileURL)
        } catch {
                print("Error loading audio file: \(error)")
        }
    }
        
    func play() {
        guard let audioFile = self.audioFile else {
            print("Error: audio file not loaded.")
            return
        }
        
        let audioFormat = audioFile.processingFormat
        let audioFrameCount = UInt32(audioFile.length)
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount) else {
            print("Error creating audio buffer.")
            return
        }
        
        do {
            try audioFile.read(into: audioBuffer)
        } catch {
            print("Error reading audio file into buffer: \(error)")
            return
        }
        
        self.audioEngine.connect(self.audioPlayerNode, to: self.mainMixerNode, format: audioBuffer.format)
        self.audioPlayerNode.scheduleBuffer(audioBuffer, at: nil, options: .loops, completionHandler: nil)
        
        do {
            try self.audioEngine.start()
            self.audioPlayerNode.play()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    func adjustSPL(spl: Float) {
        self.mainMixerNode.outputVolume = spl
    }
    
    func changeSPL(diffSPL: Float) {
        self.spl += diffSPL
        if self.spl > 1.00 {
            self.spl = 1.00
        }
        if self.spl < 0.00 {
            self.spl = 0.00
        }
        adjustSPL(spl: self.spl)
    }
    
    func stop() {
        self.audioPlayerNode.stop()
        self.audioEngine.stop()
    }
}

