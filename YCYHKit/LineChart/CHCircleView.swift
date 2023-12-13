//
//  CHCircleView.swift
//  CHLineChart
//
//  Created by evan on 2023/5/31.
//

import SwiftUI

struct CHCircleView<S: Shape>: View {
    
    private let shape: S
    private let config: CHCircleConfig
    
    init(shape: S = Circle(), config: CHCircleConfig = CHCircleConfig()) {
        self.shape = shape
        self.config = config
    }
    
    var body: some View {
        shape
            .fill(config.fillColor)
            .frame(width: config.edgeLength, height: config.edgeLength, alignment: .center)
            .overlay(
                shape
                    .trim(from: 0, to: config.trim ? config.progress : 1)
                    .stroke(config.borderColor, style: StrokeStyle(lineWidth: config.borderLineWidth, lineCap: .round))
                    .rotationEffect(Angle(degrees: config.degrees))
            )
    }
}

class CHCircleConfig {
    
    public var borderColor: Color
    public var borderLineWidth: CGFloat
    public var fillColor: Color
    public var edgeLength: CGFloat
    public var trim = false
    public var progress = 0.0
    public var degrees: Double = -90
    
    init(borderColor: Color = .blue, borderLineWidth: CGFloat = 2, fillColor: Color = .clear, edgeLength: CGFloat = 6, trim: Bool = false, progress: Double = 0, degrees: Double = -90) {
        self.borderColor = borderColor
        self.borderLineWidth = borderLineWidth
        self.fillColor = fillColor
        self.edgeLength = edgeLength
        self.trim = trim
        self.progress = progress
        self.degrees = degrees
    }
}

struct CHCircleView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack(content: {
            CHCircleView(config: CHCircleConfig(borderColor: .gray.opacity(0.5), borderLineWidth: 5, edgeLength: 100))
            CHCircleView(config: CHCircleConfig(borderColor: .green, borderLineWidth: 5, edgeLength: 100, trim: true, progress: 0.5))
//            ForEach(0..<25) { index in
//                CHCircleView(config: CHCircleConfig(borderColor: Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1)), borderLineWidth: 20, edgeLength: 100, trim: true, progress: 1.0/25.0, degrees: 360.0/25.0 * Double(index)))
//            }
        })
    }
}
