///
///
///Project name: AdHocLoudspeakerArray
/// Class name: LoudspeakerInformationsDictionary
/// Creator: Kazuki Fujita
/// Update: 2023/11/27 (Mon)
///
/// ---Explanation---
/// Loudspeaker Informations Dictionary
///
///

import Foundation
import NearbyInteraction
import MultipeerConnectivity

class LoudspeakerInformationsDictionary: NSObject {
    
    var dictionary: [NIDiscoveryToken: LoudspeakerInfoModel]
    
    override init() {
        self.dictionary = [:]
        super.init()
    }
    
    // MARK: - Updating methods
    func updateValue(key: NIDiscoveryToken, loudspeakerInfoModel: LoudspeakerInfoModel){
        self.dictionary.updateValue(loudspeakerInfoModel, forKey: key)
    }
    
    func updateValue(key: NIDiscoveryToken, loudspeakerInfoMessage: LoudspeakerInfoMessage){
       
        if let loudspeakerInfo: LoudspeakerInfoModel = self.dictionary[key] {
            
            loudspeakerInfo.update(loudspeakerInfoMessage: loudspeakerInfoMessage)
            self.dictionary.updateValue(loudspeakerInfo, forKey: key)
            
        }else{
            print("Debug(lsDict): Can't imput the data.")
        }
    }
    
    func updateValue(key: NIDiscoveryToken, isConvexHull: Bool, x: Float, y: Float, z: Float){
       
        if let loudspeakerInfo: LoudspeakerInfoModel = self.dictionary[key] {
            
            loudspeakerInfo.update(isConvexHull: isConvexHull, x: x, y: y, z: z)
            self.dictionary.updateValue(loudspeakerInfo, forKey: key)
            
        }else{
            print("Debug(lsDict): Can't imput the data.")
        }
    }
    
    func updateValue(key: NIDiscoveryToken, isConvexHull: Bool, unitVector: simd_float3, distance: Float){
        
        if let loudspeakerInfo: LoudspeakerInfoModel = self.dictionary[key] {
            
            loudspeakerInfo.update(isConvexHull: isConvexHull, unitVector: unitVector, distance: distance)
            self.dictionary.updateValue(loudspeakerInfo, forKey: key)
            
        }else{
            print("Debug(lsDict): Can't imput the data.")
        }
    }
    
    // MARK: - Getting method
    func getValue(key: NIDiscoveryToken)->LoudspeakerInfoModel? {
        return self.dictionary[key]
    }
    
    func getLoudspeakerInfoMessage(key: NIDiscoveryToken)->LoudspeakerInfoMessage?{
        return self.dictionary[key]?.outputMessage()
    }
    
    func getMCPeerID(key: NIDiscoveryToken)->MCPeerID? {
        return self.dictionary[key]?.mcPeerID
    }
    
    func getAllLoudspeakerLocation()->[simd_float2]{
        var pointVec2: [simd_float2] = []
        for (_ , info) in self.dictionary {
            pointVec2.append(simd_float2(x: info.location.x, y: info.location.z))
        }
        return pointVec2
    }
    
    // MARK: - Resetting method
    func resetIsConvexHull(){
        for (key, _) in self.dictionary {
            self.dictionary[key]?.isConvexHull = false
        }
    }
}
