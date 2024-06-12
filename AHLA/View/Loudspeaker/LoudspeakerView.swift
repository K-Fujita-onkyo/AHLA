///
///
///Project name: AdHocLoudspeakerArray
/// Class name: LoudspeakerView
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2024/05/27
///
///
/// ---Explanation---
///
///
///

import SwiftUI

struct LoudspeakerView: View {
    
    @State private var isPresented: Bool = false
    @ObservedObject var loudspeakerModel: LoudspeakerModel  = LoudspeakerModel()
    let timer = Timer.publish(every: 0.0005, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ZStack {
            
            if loudspeakerModel.information.isConvexHull {
                Color.green
                    .edgesIgnoringSafeArea(.all)
            }else{
                Color.gray
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack{
                Text("Loudspeaker")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .bold()
                    .foregroundColor(Color.white)
                    .onReceive(timer){_ in
                        self.timerAction()
                    }
                
                Text("P2P: " + loudspeakerModel.isConnected)
                    .font(.title2)
                    .foregroundColor(Color.white)
                Text("NISession: " + loudspeakerModel.isStartNISession)
                    .font(.title2)
                    .foregroundColor(Color.white)
                Text("Text: " + loudspeakerModel.debugText)
                    .font(.title2)
                    .foregroundColor(Color.white)
                
                Text(String(loudspeakerModel.information.isConvexHull))
                    .font(.title2)
                    .foregroundColor(Color.white)
                Text("x: " + String(loudspeakerModel.information.location.x))
                    .font(.title2)
                    .foregroundColor(Color.white)
                Text("y: " + String(loudspeakerModel.information.location.y))
                    .font(.title2)
                    .foregroundColor(Color.white)
                Text("z: " + String(loudspeakerModel.information.location.z))
                    .font(.title2)
                    .foregroundColor(Color.white)
                
                HStack {
                    Button(action: {
                        self.loudspeakerModel.startBrowsing()
                    }) {
                        Text("Start Browsing")
                    }.buttonStyle(RoundedCornersButtonStyle())
                    
                    Button(action: {
                        self.loudspeakerModel.stopBrowsing()
                    }) {
                        Text("Stop Browsing")
                    }.buttonStyle(RoundedCornersButtonStyle())
                }

                HStack{
                    
                    Text("loudness: " + String(loudspeakerModel.loudnessValue))
                        .foregroundColor(Color.white)
                        .lineLimit(nil)
                    
                    VStack {
                        Text("+0.01")
                            .foregroundColor(Color.white)
                        Button(action: {
                            self.loudspeakerModel.applyLoudness(value: 1)
                        }) {
                            Image("Up")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }.buttonStyle(RoundedCornersButtonStyle())
                        Button(action: {
                            self.loudspeakerModel.applyLoudness(value: -1)
                        }) {
                            Image("Down")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }.buttonStyle(RoundedCornersButtonStyle())
                        Text("-0.01")
                            .foregroundColor(Color.white)
                    }
                    
                    VStack {
                        Text("+0.1")
                            .foregroundColor(Color.white)
                        Button(action: {
                            self.loudspeakerModel.applyLoudness(value: 10)
                        }) {
                            Image("Up")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }.buttonStyle(RoundedCornersButtonStyle())
                        Button(action: {
                            self.loudspeakerModel.applyLoudness(value: -10)
                        }) {
                            Image("Down")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }.buttonStyle(RoundedCornersButtonStyle())
                        Text("-0.1")
                            .foregroundColor(Color.white)
                    }
                }
            }
        }
    }
    
    func timerAction(){
        self.loudspeakerModel.spatializeAudioInRealTime()
    }
    
}



#Preview {
    LoudspeakerView()
}
