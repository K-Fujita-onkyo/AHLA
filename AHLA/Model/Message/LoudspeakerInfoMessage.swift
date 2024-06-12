///
///
///Project name: AdHocLoudspeakerArray
/// Class name: LoudspeakerInfoMessageModel
/// Creator: Kazuki Fujita
/// Update: 2023/11/23 (Thu)
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
