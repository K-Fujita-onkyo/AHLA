///
///
///Project name: AdHocLoudspeakerArray
/// Class name: AudioLocationInfoMessage
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2024/05/25
///

import Foundation
import simd

struct AudioLocationInfoMessage: Codable {
    var selfAudio: Bool
    var location: simd_float3
}
