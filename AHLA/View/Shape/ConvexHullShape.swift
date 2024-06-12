//
//  ConvexHullShape.swift
//  AdHoc
//
//  Created by 藤田一旗 on 2023/11/13.
//

import SwiftUI
import simd

struct ConvexHullShape: Shape {
    let points: [simd_float2]
    let outerRoomWidth: Float
    let screen: CGRect = UIScreen.main.bounds
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard points.count >= 3 else {
            return path // 3つ以上の点が必要なので、それ未満の場合は空のパスを返す
        }
        
        
        let startPoint = movePointToViewCoordinateReference(point: self.points[0])
                path.move(to: startPoint)

                for i in 1..<points.count {
                    let point = movePointToViewCoordinateReference(point: self.points[i])
                    path.addLine(to: point)
                }

                path.closeSubpath()
        
        
        return path
    }
    
    private func movePointToViewCoordinateReference(point: simd_float2)->CGPoint{
        
        let originVector: simd_float2 =  simd_float2(Float(screen.width)/2, Float(screen.width))
        let screenLengthRatioPerMeter: Float = Float(screen.width) / outerRoomWidth
 
        return CGPoint(
            x: CGFloat(originVector.x + (point.x * screenLengthRatioPerMeter)),
            y: CGFloat(originVector.y - (point.y * screenLengthRatioPerMeter))
            )
    }
}


struct ContentView: View {
    var body: some View {
        ConvexHullShape(points:[
            simd_float2(3.2, 1.0),
            simd_float2(-4.0, 2.0),
            simd_float2(-1.0, 10.0),
            simd_float2(0.0, 10.0),
            simd_float2(4.0, 8.0)], outerRoomWidth: 10)
            .fill(Color.blue)
            .position(x: 10, y: 10)
            .frame(width: 200, height: 200)
    }
}

#Preview {
    ContentView()
}
