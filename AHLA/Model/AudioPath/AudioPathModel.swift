///
///
///Project name: AdHocLoudspeakerArray
/// Class name: AudioPathModel
/// Creator: Kazuki Fujita
/// Update: 2023/11/23 (Thu)
///
/// ---Explanation---
/// AudioPathModel
///

import Foundation
import simd

class AudioPathModel: NSObject {
    
    let audioBufferSize: Int = 64
    let audioSpeed: Float = 340.5  // m/s
    let samlingRate: Int = 44100 // n/s
    let referenceDistance: Float = 1 //m
    var audioPathBuffer: [Float] = Array(repeating: 0, count: 44100)
    
//    func test(){
//        
//        let porigon: [simd_float3] = [
//            simd_float3(-1, 0, 2),
//            simd_float3(-1, 0, 4),
//            simd_float3(0, 0, 5),
//            simd_float3(1, 0, 5),
//            simd_float3(2, 0, 2)
//        ]
//        
//        let i = InnerRoomInfoMessage(locations: porigon)
//        let s1 = simd_float3(-2, 0, 1)
//        let l1 = simd_float3(-1, 0, 2)
//        
//        let s2 = simd_float3(5, 0, 5)
//        let l2 = simd_float3(1, 0, 5)
//        
//    }
    
    func getDelaySec(audioDistance: Float)->Float{
        return audioDistance / self.audioSpeed
    }
    
    func getDelayIndex(audioDistance: Float)->Int{
        let delaySec: Float = self.getDelaySec(audioDistance: audioDistance)
        return Int( Float(self.samlingRate) * delaySec)
    }
    
    // Inverse Square Raw
    func getAttenuation(audioDistance: Float) -> Float{
        return pow(self.referenceDistance, 2) / pow(audioDistance, 2)
    }
    
    func testDistance(sv: simd_float3, lv: simd_float3)->Float {
        let sv2 = simd_float2(sv.x, sv.z)
        let lv2 = simd_float2(lv.x, lv.z)
        
        return distance(sv2, lv2)
    }
    
    func judgeIntersection(p1: simd_float3, p2: simd_float3, p3: simd_float3, p4: simd_float3)->Bool{
        
        let a: simd_float2 = simd_float2(x: p1.x, y: p1.z)
        let b: simd_float2 = simd_float2(x: p2.x, y: p2.z)
        let c: simd_float2 = simd_float2(x: p3.x, y: p3.z)
        let d: simd_float2 = simd_float2(x: p4.x, y: p4.z)
        
        let cd: simd_float2 = d - c
        let ca: simd_float2 = a - c
        let cb: simd_float2 = b - c
        
        let s: simd_float3 = simd_cross(cd, ca)
        let t: simd_float3 = simd_cross(cd, cb)
        
        if s.z*t.z < 0{
            return true
        }
        
        return false
    }
    
    func judgeIntersection(audioPosition: simd_float3, loudspeakerPosition: simd_float3, innerRoom: InnerRoomInfoMessage)->Bool{
        let points: [simd_float3] = innerRoom.locations
        for i in 0..<points.count {
            if judgeIntersection(
                p1: audioPosition,
                p2: loudspeakerPosition,
                p3: points[i],
                p4: points[(i+1)%points.count]
            ) {
                return true
            }
            
        }
        
        return false
    }
    
    func judgeIntersection(audioPosition: simd_float3, loudspeakerPosition: simd_float3, imageInnerRooms: [InnerRoomInfoMessage])->Bool{
        for imageInnerRoom in imageInnerRooms {
            if self.judgeIntersection(audioPosition: audioPosition, loudspeakerPosition: loudspeakerPosition, innerRoom: imageInnerRoom) {
                return true
            }
        }
        return false
    }
    
    func getXAxisSymmetryPoint(point: simd_float3, outerRoom: OuterRoomInfoMessage)->simd_float3{
        return simd_float3(x: point.x, y: point.y, z: -point.z + outerRoom.height)
    }
    
    func getZAxisSymmetryPoint(point: simd_float3, outerRoom: OuterRoomInfoMessage)->simd_float3{
        return simd_float3(x: point.x, y: point.y, z: -point.z)
    }
    
    func getOriginAxisSymmetryPoint(point: simd_float3, outerRoom: OuterRoomInfoMessage)->simd_float3{
        var symPoint: simd_float3
        symPoint = getXAxisSymmetryPoint(point: point, outerRoom: outerRoom)
        symPoint = getZAxisSymmetryPoint(point: symPoint, outerRoom: outerRoom)
        return symPoint
    }
    
    func getSymmetryPoint(point: simd_float3, outerRoom: OuterRoomInfoMessage, reflectivePeturn: String)->simd_float3{
        var symPoint: simd_float3 = point
        switch reflectivePeturn {
        case "x":
            symPoint = self.getXAxisSymmetryPoint(point: symPoint, outerRoom: outerRoom)
            break
        case "z":
            symPoint = self.getZAxisSymmetryPoint(point: symPoint, outerRoom: outerRoom)
            break
        case "o":
            symPoint = self.getOriginAxisSymmetryPoint(point: symPoint, outerRoom: outerRoom)
            break
        default:
            break
        }
        return symPoint
    }
    
    func getSymmetryInnerRoom(innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage, reflectivePattern: String)->InnerRoomInfoMessage{
        
        var symInnerRoom: InnerRoomInfoMessage = innerRoom
        
        switch reflectivePattern {
        case "x":
            for i in 0..<innerRoom.locations.count{
                symInnerRoom.locations[i] = self.getXAxisSymmetryPoint(point: symInnerRoom.locations[i], outerRoom: outerRoom)
            }
            break
        case "z":
            for i in 0..<innerRoom.locations.count{
                symInnerRoom.locations[i] = self.getZAxisSymmetryPoint(point: symInnerRoom.locations[i], outerRoom: outerRoom)
            }
            break
        case "o":
            for i in 0..<innerRoom.locations.count{
                symInnerRoom.locations[i] = self.getXAxisSymmetryPoint(point: symInnerRoom.locations[i], outerRoom: outerRoom)
            }
            break
        default:
            break
        }
        
        return symInnerRoom
    }
    
    func moveInnerRoom(innerRoom: InnerRoomInfoMessage, movedVec: simd_float3)->InnerRoomInfoMessage{
        var movedInnerRoom: InnerRoomInfoMessage = innerRoom
        
        for i in 0 ..< movedInnerRoom.locations.count {
            movedInnerRoom.locations[i] += movedVec
        }
        
        return movedInnerRoom
    }
    
    func setDirectPath(audioBuffer: [Float], audioLocation: simd_float3, loudspeakerLocation: simd_float3){
        
        //var audioDistance: Float = distance(audioLocation, loudspeakerLocation)
        var audioDistance: Float = testDistance(sv: audioLocation, lv: loudspeakerLocation)
        
        audioDistance = audioDistance < 0.2 ? 0.2 : audioDistance
        
        let delayIndex: Int = self.getDelayIndex(audioDistance: audioDistance)
        let attenuation: Float = self.getAttenuation(audioDistance: audioDistance)
        
        var index = 0
        for audioBlock in audioBuffer {
            self.audioPathBuffer[index + delayIndex] += audioBlock*attenuation
            index += 1
        }
    }
    
    func setFirstReflectedPath(audioBuffer: [Float], audioLocation: simd_float3, loudspeakerLocation: simd_float3, innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage, reflectivePattern: String, movedVec: simd_float3){
        
        var symInnerRoom: InnerRoomInfoMessage =  self.getSymmetryInnerRoom(innerRoom: innerRoom, outerRoom: outerRoom, reflectivePattern: reflectivePattern)
        var symLoudspeakerLocation: simd_float3 = self.getSymmetryPoint(point: loudspeakerLocation, outerRoom: outerRoom, reflectivePeturn: reflectivePattern)
        
        symInnerRoom = self.moveInnerRoom(innerRoom: symInnerRoom, movedVec: movedVec)
        symLoudspeakerLocation = symLoudspeakerLocation + movedVec
        
        if !judgeIntersection(audioPosition: audioLocation, loudspeakerPosition: symLoudspeakerLocation, imageInnerRooms: [innerRoom, symInnerRoom]) {
            var audioDistance: Float = testDistance(sv: audioLocation, lv: symLoudspeakerLocation)
            audioDistance = audioDistance < 0.2 ? 0.2 : audioDistance
            let delayIndex: Int = self.getDelayIndex(audioDistance: audioDistance)
            let attenuation: Float = self.getAttenuation(audioDistance: audioDistance)
            
            var index = 0
            for audioBlock in audioBuffer {
                self.audioPathBuffer[index + delayIndex] += audioBlock*attenuation*outerRoom.wallCoefficient
                index += 1
            }
        }
    }
    
    //for up down left right
    func setSecondReflectedPath(audioBuffer: [Float], audioLocation: simd_float3, loudspeakerLocation: simd_float3, innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage, reflectivePattern: String, movedVec: simd_float3){
        
        let firstSymInnerRoom: InnerRoomInfoMessage = self.moveInnerRoom(
            innerRoom: self.getSymmetryInnerRoom(innerRoom: innerRoom, outerRoom: outerRoom, reflectivePattern: reflectivePattern),
            movedVec: movedVec/2
        )
        
        let secondSymInnerRoom: InnerRoomInfoMessage = self.moveInnerRoom(
            innerRoom: innerRoom,
            movedVec: movedVec
        )
        
        let symLoudspeakerLocation: simd_float3  = loudspeakerLocation + movedVec
        
        if !self.judgeIntersection(
            audioPosition: audioLocation,
            loudspeakerPosition: symLoudspeakerLocation,
            imageInnerRooms: [innerRoom, firstSymInnerRoom, secondSymInnerRoom]
        ) {
            
            var audioDistance: Float = testDistance(sv: audioLocation, lv: symLoudspeakerLocation)
            audioDistance = audioDistance < 0.2 ? 0.2 : audioDistance
            let delayIndex: Int = self.getDelayIndex(audioDistance: audioDistance)
            let attenuation: Float = self.getAttenuation(audioDistance: audioDistance)
            
            var index = 0
            for audioBlock in audioBuffer {
                self.audioPathBuffer[index + delayIndex] += audioBlock*attenuation*pow(outerRoom.wallCoefficient, 2)
                index += 1
            }
            
        }
    }
    
    // for diagonal
    func setSecondReflectedPath(audioBuffer: [Float], audioLocation: simd_float3, loudspeakerLocation: simd_float3, innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage, movedVec: simd_float3){
        
        let firstXSymInnerRoom: InnerRoomInfoMessage = self.moveInnerRoom(
            innerRoom: self.getSymmetryInnerRoom(innerRoom: innerRoom, outerRoom: outerRoom, reflectivePattern: "x"),
            movedVec: simd_float3(0, 0, movedVec.z)
        )
        
        let firstZSymInnerRoom: InnerRoomInfoMessage = self.moveInnerRoom(
            innerRoom: self.getSymmetryInnerRoom(innerRoom: innerRoom, outerRoom: outerRoom, reflectivePattern: "z"),
            movedVec: simd_float3(movedVec.x, 0, 0)
        )
        
        let secondSymInnerRoom: InnerRoomInfoMessage = self.moveInnerRoom(
            innerRoom: self.getSymmetryInnerRoom(innerRoom: innerRoom, outerRoom: outerRoom, reflectivePattern: "o"),
            movedVec: movedVec
        )
        
        let symLoudspeakerLocation: simd_float3  = loudspeakerLocation + movedVec
        
        if !self.judgeIntersection(
            audioPosition: audioLocation,
            loudspeakerPosition: symLoudspeakerLocation,
            imageInnerRooms: [innerRoom, firstXSymInnerRoom, firstZSymInnerRoom, secondSymInnerRoom]
        ) {
            
            var audioDistance: Float = testDistance(sv: audioLocation, lv: symLoudspeakerLocation)
            audioDistance = audioDistance < 0.2 ? 0.2 : audioDistance
            let delayIndex: Int = self.getDelayIndex(audioDistance: audioDistance)
            let attenuation: Float = self.getAttenuation(audioDistance: audioDistance)
            
            var index = 0
            for audioBlock in audioBuffer {
                self.audioPathBuffer[index + delayIndex] += audioBlock*attenuation*pow(outerRoom.wallCoefficient, 2)
                index += 1
            }
            
        }
    }
    
    func setFirstReflectedPaths(audioBuffer: [Float], audioLocation: simd_float3, loudspeakerLocation: simd_float3, innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage){
        
        //Up
        self.setFirstReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "x",
            movedVec: simd_float3(0, 0, outerRoom.height)
        )
        
        //Down
        self.setFirstReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "x",
            movedVec: simd_float3(0, 0, -outerRoom.height)
        )
        
        //Left
        self.setFirstReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "z",
            movedVec: simd_float3(-outerRoom.width, 0, 0)
        )
        
        //Right
        self.setFirstReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "z",
            movedVec: simd_float3(outerRoom.width, 0, 0)
        )
    }
    
    func setSecondReflectedPaths(audioBuffer: [Float], audioLocation: simd_float3, loudspeakerLocation: simd_float3, innerRoom: InnerRoomInfoMessage, outerRoom: OuterRoomInfoMessage){
        
        // Up
        self.setSecondReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "x",
            movedVec: simd_float3(0, 0, outerRoom.height*2)
        )
        
        // Down
        self.setSecondReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "x",
            movedVec: simd_float3(0, 0, -outerRoom.height*2)
        )
        
        // Left
        self.setSecondReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "z",
            movedVec: simd_float3(-outerRoom.width*2, 0, 0)
        )
        
        // Right
        self.setSecondReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            reflectivePattern: "z",
            movedVec: simd_float3(outerRoom.width*2, 0, 0)
        )
        
        // Upper right diagonal
        self.setSecondReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            movedVec: simd_float3(outerRoom.width, 0, outerRoom.height)
        )
        
        // Lower right diagonal
        self.setSecondReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            movedVec: simd_float3(outerRoom.width, 0, -outerRoom.height)
        )
        
        // Upper left diagonal
        self.setSecondReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            movedVec: simd_float3(-outerRoom.width, 0, outerRoom.height)
        )
        
        // Lower left diagonal
        self.setSecondReflectedPath(
            audioBuffer: audioBuffer,
            audioLocation: audioLocation,
            loudspeakerLocation: loudspeakerLocation,
            innerRoom: innerRoom,
            outerRoom: outerRoom,
            movedVec: simd_float3(-outerRoom.width, 0, -outerRoom.height)
        )
        
    }
    
    func getPathFromBuffer()->[Float]{
        if self.audioPathBuffer.count > self.audioBufferSize {
            let audioPath: [Float] = Array(self.audioPathBuffer[0 ..< self.audioBufferSize])
            self.audioPathBuffer.removeFirst(self.audioBufferSize)
            self.audioPathBuffer = self.audioPathBuffer + Array(repeating: 0, count: self.audioBufferSize)
            return audioPath
        }else {
            let audioPath: [Float] =  Array(repeating: 0, count: self.audioBufferSize)
            self.audioPathBuffer = self.audioPathBuffer + Array(repeating: 0, count: self.audioBufferSize)
            return audioPath
        }
    }
    
    func applyLoudness(audioFloatArray: [Float], loudness: Float)->[Float]{
        let size:Int = audioFloatArray.count
        var audioFloatBuffer: [Float] = []
        for i in 0..<size {
            audioFloatBuffer.append(audioFloatArray[i] * loudness)
        }
        return audioFloatBuffer
    }
    
    func calcAudioPath(
        audioFloatArray: [Float],
        audioLocation: simd_float3,
        loudspeakerLocation: simd_float3,
        innerRoom: InnerRoomInfoMessage,
        outerRoom: OuterRoomInfoMessage
    )->[Float]{
        self.setDirectPath(audioBuffer: audioFloatArray, audioLocation: audioLocation, loudspeakerLocation: loudspeakerLocation)
        self.setFirstReflectedPaths(audioBuffer: audioFloatArray, audioLocation: audioLocation, loudspeakerLocation: loudspeakerLocation, innerRoom: innerRoom, outerRoom: outerRoom)
        self.setSecondReflectedPaths(audioBuffer: audioFloatArray, audioLocation: audioLocation, loudspeakerLocation: loudspeakerLocation, innerRoom: innerRoom, outerRoom: outerRoom)
        return getPathFromBuffer()
    }
}
