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
                    .stroke(config.borderColor, lineWidth: config.borderLineWidth)
            )
    }
}

class CHCircleConfig {
    
    public var borderColor: Color
    public var borderLineWidth: CGFloat
    public var fillColor: Color
    public var edgeLength: CGFloat
    
    init(borderColor: Color = .blue, borderLineWidth: CGFloat = 2, fillColor: Color = .clear, edgeLength: CGFloat = 6) {
        self.borderColor = borderColor
        self.borderLineWidth = borderLineWidth
        self.fillColor = fillColor
        self.edgeLength = edgeLength
    }
}

struct CHCircleView_Previews: PreviewProvider {
    static var previews: some View {
        CHCircleView(config: CHCircleConfig(borderColor: .orange, borderLineWidth: 5, fillColor: .purple, edgeLength: 100))
    }
}
