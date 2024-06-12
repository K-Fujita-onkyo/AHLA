///
///
///Project name: AdHocLoudspeakerArray
/// Class name: TopView
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2024/05/25
///
/// ---Explanation---
///User can select a role in the buttons.
///There are two roles, audio operator and loudspeaker.
///Please check the SPL using before playing.
///
import SwiftUI

struct TopView: View {
    
    @State private var showLoudspeakerView: Bool = false
    @State private var showSoundOpelatorView: Bool = false
    @State private var showMesuringSPLView: Bool = false
    
    private  var columnList: [ColumnStyle] = [
        ColumnStyle(id: 0, name: "Loudspeaker", imageName: "LoudspeakerMark"),
        ColumnStyle(id: 1, name: "Audio operator", imageName: "AudioOperatorMark"),
        ColumnStyle(id: 2, name: "Mesuring SPL", imageName: "MesuringSPLMark"),
    ]
    
    var body: some View {
        VStack {
            Text("Please select your column.")
                .font(.title2)
                .foregroundColor(Color.white)
            
            Button(action: {
                self.showLoudspeakerView.toggle()
            }) {
                ColumnListStyle(column: columnList[0])
            }.sheet(isPresented: self.$showLoudspeakerView) {
                LoudspeakerView()
            }.buttonStyle(RoundedCornersButtonStyle())
            
            Button(action: {
                self.showSoundOpelatorView.toggle()
            }) {
                ColumnListStyle(column: columnList[1])
            }.sheet(isPresented: self.$showSoundOpelatorView) {
                AudioOperatorView()
            }.buttonStyle(RoundedCornersButtonStyle())

            Button(action: {
                self.showMesuringSPLView.toggle()
            }) {
                ColumnListStyle(column: columnList[2])
            }.sheet(isPresented: self.$showMesuringSPLView) {
                LoudnessTestView()
            }.buttonStyle(RoundedCornersButtonStyle())
        }
        .padding()
    }
}


#Preview {
    TopView()
}

