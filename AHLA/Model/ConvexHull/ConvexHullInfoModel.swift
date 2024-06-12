///
///
///Project name: AdHocLoudspeakerArray
/// Class name: ConvexHullInfoModel
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2024/05/28
///
/// ---Explanation---
/// ConvexHullInfoModel calculates the convex hull created by loudspeakers.
///
///

import Foundation
import NearbyInteraction

typealias NIVector =  (niDiscoveryToken: NIDiscoveryToken?, location: simd_float3)

class ConvexHullInfoModel: NSObject {
    
    var points: [NIVector]
    var convexHull: StackModel<NIVector>
    
    override init() {
        self.points = []
        self.convexHull = StackModel(array: [])
        super.init()
    }
    
    func appendAPoint(niDiscoveryToken: NIDiscoveryToken?, location: simd_float3){
        self.points.append(NIVector(niDiscoveryToken: niDiscoveryToken, location: location))
    }
    
    func getSmallestZPoint() ->NIVector {
        
        var smallestZPoint: NIVector
        var smallestZIndex: Int
        
        // Initialize these instances.
        smallestZPoint = (niDiscoveryToken: nil, location: simd_float3(x: Float.infinity, y: Float.infinity, z: Float.infinity))
        smallestZIndex = -1
        
        // Find a point with the smallest z axis.
        for index in 0 ..< self.points.count {
            if smallestZPoint.location.z > self.points[index].location.z {
                smallestZIndex = index
                smallestZPoint = self.points[index]
            }
        }
        
        //Remove the smallest z point in points.
        self.points.remove(at: smallestZIndex)
        
        return smallestZPoint
    }
    
    func getAngleBetweenVectorsOnXZPlane(originalVector: simd_float3, referenceVector: simd_float3) -> Float {
        let myVec2: simd_float2 = simd_float2(originalVector.x, originalVector.z)
        let refVec2: simd_float2 = simd_float2(referenceVector.x, referenceVector.z)
        let dotProduct = simd_dot(myVec2, refVec2)
        let magnitudeProduct = simd_length(myVec2) * simd_length(refVec2)
        return acos(dotProduct / magnitudeProduct)
    }
    
    func sortPointsByRefPoint(referencePoint: NIVector){
        self.points.sort(by: {point1, point2 -> Bool in
            let normVec1: simd_float3 = normalize(point1.location - referencePoint.location)
            let normVec2: simd_float3 = normalize(point2.location - referencePoint.location)
            let normRefVec: simd_float3 = simd_float3(x: 1, y: 0, z: 0)
            
            let  angle1 = getAngleBetweenVectorsOnXZPlane(originalVector: normVec1, referenceVector: normRefVec)
            let angle2 = getAngleBetweenVectorsOnXZPlane(originalVector: normVec2, referenceVector: normRefVec)
            
            return angle1 < angle2
        })
    }
    
    func isLeftTurn(vec1: simd_float3, vec2: simd_float3, vec3: simd_float3)->Bool{
        
        let matrix: [[Float]] = [
            [vec1.x, vec2.x, vec3.x],
            [vec1.z, vec2.z, vec3.z],
            [1.0, 1.0, 1.0]
        ]
        
        var det: Float = 0
        
        det += matrix[0][0]*matrix[1][1]*matrix[2][2]
        det -= matrix[0][0]*matrix[1][2]*matrix[2][1]
        det += matrix[0][1]*matrix[1][2]*matrix[2][0]
        det -= matrix[0][1]*matrix[1][0]*matrix[2][2]
        det += matrix[0][2]*matrix[1][0]*matrix[2][1]
        det -= matrix[0][2]*matrix[1][1]*matrix[2][0]
        
        if(det>0){
            return true
        }else {
            return false
        }
    }
    
    func calculateConvexHull(){
        
        if self.points.count < 1 {
            return
        }
        
        let smallestZPoint = self.getSmallestZPoint()
        // Push a point with the smallest z axis into a stack of convex hull
        self.convexHull.push(element: smallestZPoint)
        self.sortPointsByRefPoint(referencePoint: smallestZPoint)
        self.convexHull.pushArray(elements: self.points)
        
        var index: Int = 0
        
        if self.convexHull.size > 3 {
            while self.convexHull.size > index + 2 {
                if self.isLeftTurn(
                    vec1: self.convexHull.array[index].location,
                    vec2: self.convexHull.array[index + 1].location,
                    vec3: self.convexHull.array[index + 2].location
                ) {
                    index += 1
                } else {
                    self.convexHull.array.remove(at: index + 1)
                    if index - 1 >= 0 {
                        index -= 1
                    }
                }
            }
        }
        
    }
    
}

extension ConvexHullInfoModel {
    
    func reset(){
        self.points = []
        self.convexHull = StackModel(array: [])
    }
    
    func appendPointsByLIDict(loudspeakerInfoDict: LoudspeakerInformationsDictionary){
        for (niDiscoveryToken, loudspeakerInfo) in loudspeakerInfoDict.dictionary {
            self.appendAPoint(niDiscoveryToken: niDiscoveryToken, location: loudspeakerInfo.location)
        }
    }
    
    func getConvPoints()->[simd_float2]{
        var convPoint: [simd_float2] = []
        for pointVec3 in self.convexHull.array {
            let pointVec2: simd_float2 = simd_float2(x: pointVec3.location.x, y: pointVec3.location.z)
            convPoint.append(pointVec2)
        }
        return convPoint
    }
    
    func getInnerRoomInfoMessage()->InnerRoomInfoMessage{
        var locations: [simd_float3] = []
        for pointVec3 in self.convexHull.array {
            locations.append(simd_float3(x: pointVec3.location.x, y: pointVec3.location.y, z: pointVec3.location.z))
        }
        return InnerRoomInfoMessage(locations: locations)
    }
    
}
