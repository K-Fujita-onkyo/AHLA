//
//  AudioLocationInfoMessage.swift
//  AdHocLoudspeakerArray
//
//  Created by 藤田一旗 on 2023/12/31.
//

import Foundation
import simd

struct AudioLocationInfoMessage: Codable {
    var selfAudio: Bool
    var location: simd_float3
}
