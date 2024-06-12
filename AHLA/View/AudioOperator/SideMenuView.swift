///
///
///Project name: AdHocLoudspeakerArray
/// Class name: TopView
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2024/05/25
///
///

import SwiftUI

struct SideMenuView: View {
    @Binding var isOpen: Bool
    @Binding var outerRoomInfo: OuterRoomInfoModel
    @Binding var soWidth: Float
    @Binding var soHeight: Float
    @State var width: Float = 5
    @State var height: Float = 5
    @State var wallCoefficient: Float = 0.05
    @State var wallType: String = "concrete"
    let screenWidth: CGFloat = 270
    
    var body: some View {
    
        let keys: [String] = outerRoomInfo.wallTypeDict.map{$0.key}
        
        ZStack {
            // 背景部分
            GeometryReader { geometry in
                EmptyView()
            }
            .background(Color.red.opacity(0.75))
            .opacity(self.isOpen ? 1.0 : 0.0)
            .opacity(1.0)
            .animation(.easeIn(duration: 0.25), value: false)
            .onTapGesture {
                self.isOpen = false
            }

            // Todo: ここにリスト部分を実装する
            VStack{
                
                HStack{
                    Text("Width: " + String(self.soWidth) + "(m)")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color.white)
                   
                    Button(action: {
                        self.outerRoomInfo.decreaseWidth()
                        self.width = self.outerRoomInfo.width
                        self.soWidth = self.outerRoomInfo.width
                    }) {
                        Image("Down")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }.buttonStyle(RoundedCornersButtonStyle())
                    
                    Button(action: {
                        self.outerRoomInfo.increaseWidth()
                        self.width = self.outerRoomInfo.width
                        self.soWidth = self.outerRoomInfo.width
                    }) {
                        Image("Up")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }.buttonStyle(RoundedCornersButtonStyle())
                    
                }
            
                HStack{
                    Text("Height: " + String(self.height) + "(m)")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color.white)
                    
                    Button(action: {
                        self.outerRoomInfo.decreaseHeight()
                        self.height = self.outerRoomInfo.height
                        self.soHeight = self.outerRoomInfo.height
                    }) {
                        Image("Down")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }.buttonStyle(RoundedCornersButtonStyle())
                    
                    Button(action: {
                        self.outerRoomInfo.increaseHeight()
                        self.height = self.outerRoomInfo.height
                        self.soHeight = self.outerRoomInfo.height
                    }) {
                        Image("Up")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }.buttonStyle(RoundedCornersButtonStyle())
                }
                
                HStack{
                    Text("Wall type: " + self.wallType)
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color.white)
                    VStack{
                        ForEach(0..<keys.count) { i in
                            Button(action: {
                                self.outerRoomInfo.setWallCoefficient(type: keys[i])
                                self.wallType = keys[i]
                            }) {
                                Text(keys[i])
                                    .bold()
                                    .padding()
                                    .frame(width: 120, height: 50)
                                    .foregroundColor(Color.white)
                                    .background(Color.orange)
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
                
            }.frame(width: self.screenWidth)
                .offset(x: self.isOpen ? 0 : -self.screenWidth*2)
                .animation(.easeIn(duration: 0.25), value: true)
                Spacer()
        }
    }
}
