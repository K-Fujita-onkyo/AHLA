///
///
///Project name: AdHocLoudspeakerArray
/// Class name: LoudspeakerInfoModel
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2024/05/25
///
///
/// ---Explanation---
///
///
///

import Foundation
import NearbyInteraction
import MultipeerConnectivity

class LoudspeakerInfoModel: NSObject {
    
    var mcPeerID: MCPeerID!
    var isConvexHull: Bool
    var location: simd_float3
    
    override init(){
        self.mcPeerID = nil
        self.isConvexHull = false
        self.location = simd_float3(x: 0, y: 0, z: 0)
        super.init()
    }
    
    init(mcPeerID: MCPeerID) {
        self.mcPeerID = mcPeerID
        self.isConvexHull = false
        self.location = simd_float3(x: 0, y: 0, z: 0)
    }
    
    init(mcPeerID: MCPeerID, location: simd_float3){
        self.mcPeerID = mcPeerID
        self.isConvexHull = false
        self.location = location
    }
    
    init(mcPeerID: MCPeerID, isConvexHull: Bool, location: simd_float3){
        self.mcPeerID = mcPeerID
        self.isConvexHull = isConvexHull
        self.location = location
    }
    
    init(mcPeerID: MCPeerID, x: Float, y: Float, z: Float){
        self.mcPeerID = mcPeerID
        self.isConvexHull = false
        self.location = simd_float3(x: x, y: y, z: z)
    }
    
    init(mcPeerID: MCPeerID, isConvexHull: Bool, x: Float, y: Float, z: Float){
        self.mcPeerID = mcPeerID
        self.isConvexHull = isConvexHull
        self.location = simd_float3(x: x, y: y, z: z)
    }
    
    func update(loudspeakerInfoMessage: LoudspeakerInfoMessage){
        self.isConvexHull = loudspeakerInfoMessage.isConvexHull
        self.location = loudspeakerInfoMessage.location
    }
    
    func update(isConvexHull: Bool, location: simd_float3){
        self.isConvexHull = isConvexHull
        self.location = location
    }
    
    func update(isConvexHull: Bool, x: Float, y: Float, z: Float){
        self.isConvexHull = isConvexHull
        self.location = simd_float3(x: x, y: y, z: z)
    }
    
    func update(isConvexHull: Bool, unitVector: simd_float3, distance: Float){
        self.isConvexHull = isConvexHull
        self.location = unitVector * distance
    }
    
    func outputMessage()->LoudspeakerInfoMessage{
        return LoudspeakerInfoMessage(isConvexHull: self.isConvexHull, location: self.location)
    }
}
