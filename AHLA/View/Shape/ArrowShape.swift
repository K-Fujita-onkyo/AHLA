//
//  ArrowShape.swift
//  AdHoc
//
//  Created by 藤田一旗 on 2023/11/14.
//

import SwiftUI

struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.midY - 10))
        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.midY + 10))
        return path
    }
}

struct ArrowView: View {
    var body: some View {
        ArrowShape()
            .stroke(Color.black, lineWidth: 2) // 線の色と太さを設定
            .frame(width: 400, height: 100)
    }
}

#Preview {
    ArrowView()
}

