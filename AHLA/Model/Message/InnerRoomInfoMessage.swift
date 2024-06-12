//
//  InnerRoomInfoMessage.swift
//  AdHocLoudspeakerArray
//
//  Created by 藤田一旗 on 2023/12/05.
//

import Foundation
import simd
struct InnerRoomInfoMessage: Codable {
    var locations: [simd_float3]
}
