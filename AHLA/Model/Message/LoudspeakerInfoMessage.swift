///
///
///Project name: AdHocLoudspeakerArray
/// Class name: LoudspeakerInfoMessage
/// Creator: Kazuki Fujita
/// Created at: 2023/11/27
/// Updated at: 2024/05/25
///
///
/// ---Explanation---
/// Loudspeaker model
///
///

import Foundation
import simd

struct LoudspeakerInfoMessage: Codable {
    var isConvexHull: Bool
    var location: simd_float3
}
