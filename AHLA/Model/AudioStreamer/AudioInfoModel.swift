///
///
///Project name: AdHocLoudspeakerArray
/// Class name: TopView
/// Creator: Kazuki Fujita
/// Created at: 2023/12/30
/// Updated at: 2024/02/12
///
/// ---Explanation---
/// This is a model class that holds a float array of audio.
///

import Foundation
import AVFoundation

class AudioInfoModel: NSObject {
    
    let samplingRate: Int = 44100
    let bufferSize: Int = 1024
    let audioBuffer: [[Float]] = []
    
    override init(){
        super.init()
    }
    
    init(resourceName: String, type: String) {
    }
    
    func audioToFloatArray(audioURL: URL) -> [Float]? {
        
        do {
            // Read an audio file as AVAudioFile
            let audioFile = try AVAudioFile(forReading: audioURL)
            
           // Get a format of audioFile
            guard let format = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: audioFile.fileFormat.sampleRate,
                channels: audioFile.fileFormat.channelCount,
                interleaved: false
            ) else {
                print("Cannot create AVAudioFormat")
                return nil
            }
            
            // Read PCM data
            guard let audioBuffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ) else {
                print("Cannot create AVAudioPCMBuffer")
                return nil
            }
            
            try audioFile.read(into: audioBuffer)
            
            // Convert PCM buffer to Float array
            let floatArray = Array(
                UnsafeBufferPointer(
                    start: audioBuffer.floatChannelData?[0],
                    count:Int(audioBuffer.frameLength)
                )
            )
            
            return floatArray
            
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
            return nil
        }
    }
    
}
