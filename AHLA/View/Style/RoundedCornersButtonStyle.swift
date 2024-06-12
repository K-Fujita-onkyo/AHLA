///
///
///Project name: AdHocLoudspeakerArray
/// Class name: RoundedCornersButtonStyle
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2023/12/12
///
/// ---Explanation---
///This is a style class for matching button designs.
///
import Foundation
import SwiftUI

struct RoundedCornersButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(Color.white)
            .background(configuration.isPressed ? Color.red : Color.orange)
            .cornerRadius(12.0)
        }
}
