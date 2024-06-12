///
///
///Project name: AdHocLoudspeakerArray
/// Class name: OuterRoomInfoModel
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2024/06/01
///
/// ---Explanation---
/// OuterRoomInfoModel is determines the size and texture of a outer room.
///
///
import Foundation

class OuterRoomInfoModel: NSObject {
    
    var width: Float
    var height: Float
    var wallCoefficient: Float
    var wallType: String
    
    var wallTypeDict: Dictionary<String, Float> = [
        "plaster" : 0.02,
        "concrete": 0.05,
        "glass" : 0.15,
        "hardwood" : 0.3,
        "cork sheet": 0.1,
        "acoustic tiles" : 0.6
    ]
    
    override init() {
        self.width = 5
        self.height = 5
        self.wallCoefficient = 0.05 // Concrete block, painted
        self.wallType = "concrete"
        super.init()
    }
    
    init(width: Float, height: Float, wallType: String) {
        self.width = width
        self.height = height
        self.wallType = wallType
        if wallTypeDict[wallType] != nil {
            self.wallCoefficient = wallTypeDict[wallType]!
        }else{
            self.wallCoefficient = 0.05
        }
    }
    
    func increaseWidth(){
        if self.width + 1 < 30 {
            self.width += 1
        }
    }
    
    func decreaseWidth(){
        if self.width - 1 > 2 {
            self.width -= 1
        }
    }
    
    func increaseHeight(){
        if self.height + 1 < 30 {
            self.height += 1
        }
    }
    
    func decreaseHeight(){
        if self.height - 1 > 2 {
            self.height -= 1
        }
    }
    
    func setWallCoefficient(type: String){
        self.wallCoefficient = wallTypeDict[type]!
        self.wallType = type
    }
    
    func getOuterRoomInfoMessage()->OuterRoomInfoMessage {
        return OuterRoomInfoMessage(width: self.width, height: self.height, wallCoefficient: self.wallCoefficient)
    }
}
