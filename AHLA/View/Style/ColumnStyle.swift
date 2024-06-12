///
///
///Project name: AdHocLoudspeakerArray
/// Class name: ColumnStyle
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2023/12/12
///
/// ---Explanation---
///This style class is used to set images and text.
///
import Foundation
import SwiftUI

struct ColumnStyle: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var discription: String
    private var imageName: String
    var image: Image{
        Image(imageName)
    }
    
    init(){
        self.id = 0
        self.name = "none"
        self.discription = "none"
        self.imageName = "Sample"
    }
    
    init(id: Int, name: String, discription: String, imageName: String){
        self.id = id
        self.name = name
        self.discription = discription
        self.imageName = imageName
    }
    
    init(id: Int, name: String, imageName: String){
        self.id = id
        self.name = name
        self.discription = "none"
        self.imageName = imageName
    }
}
