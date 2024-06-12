//
//  LoudnessTestView.swift
//  AdHocLoudspeakerArray
//
//  Created by 藤田一旗 on 2024/06/06.
//

import SwiftUI

struct LoudnessTestView: View {

    @ObservedObject var loudnessTestModel: LoudnessTestModel = LoudnessTestModel()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack{
                Text("LoudnessTest")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .bold()
                    .foregroundColor(Color.white)
                
                Text("Please maximize the volume on your phone.")
                    .foregroundColor(Color.white)
                Text("")
                Text("Loudness Setting ")
                    .font(.title2)
                    .foregroundColor(Color.white)
                Text("")
                Text("Audio")
                    .font(.title2)
                    .foregroundColor(Color.white)
                
                HStack {
                    Button(action: {
                        self.loudnessTestModel.play()
                   }) {
                       Text("Play")
                           .foregroundColor(Color.white)
                   }.buttonStyle(RoundedCornersButtonStyle())
                    Button(action: {
                        self.loudnessTestModel.stop()
                   }) {
                       Text("Stop")
                           .foregroundColor(Color.white)
                   }.buttonStyle(RoundedCornersButtonStyle())
                    
                    
                }

                HStack{
                    
                    Text("SPL change: " + String(format: "%.2f", self.loudnessTestModel.spl))
                        .foregroundColor(Color.white)
                        .lineLimit(nil)
                    
                    VStack {
                        Text("+0.01")
                            .foregroundColor(Color.white)
                        Button(action: {
                            self.loudnessTestModel.changeSPL(diffSPL: 0.0100)
                        }) {
                            Image("Up")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }.buttonStyle(RoundedCornersButtonStyle())
                        Button(action: {
                            self.loudnessTestModel.changeSPL(diffSPL: -0.0100)
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
                            self.loudnessTestModel.changeSPL(diffSPL: +0.100)
                        }) {
                            Image("Up")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }.buttonStyle(RoundedCornersButtonStyle())
                        Button(action: {
                            self.loudnessTestModel.changeSPL(diffSPL: -0.100)
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
}

#Preview {
    LoudnessTestView()
}
