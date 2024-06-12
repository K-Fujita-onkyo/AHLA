///
///
///Project name: AdHocLoudspeakerArray
/// Class name: InnerRoomInfoMessage
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2024/05/25
///

import Foundation
import simd
struct InnerRoomInfoMessage: Codable {
    var locations: [simd_float3]
}
