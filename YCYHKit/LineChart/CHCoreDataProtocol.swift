//
//  CHCoreDataProtocol.swift
//  CHLineChart
//
//  Created by evan on 2023/5/29.
//

import Foundation

protocol CHCoreDataProtocol {
    func points(forData data: [Double], range: [Double], size: CGSize, lineWidth: CGFloat) -> [CGPoint]
    func lineWidth(visualType: CHVisualType) -> CGFloat
}

extension CHCoreDataProtocol {
    
    func points(forData data: [Double], range: [Double], size: CGSize, lineWidth: CGFloat) -> [CGPoint] {
        var vector = CHMath.stretchOut(CHMath.norm(data + range))
        for _ in 0 ..< range.count {
            vector.removeLast()
        }
        var points: Array<CGPoint> = []
        if vector.count == 1 {
            points.append(CGPoint(x: 0, y: (size.height - lineWidth) * CGFloat(vector.first!) + lineWidth / 2))
            return points
        }
        for index in 0 ..< vector.count {
            let x = size.width / CGFloat(vector.count - 1) * CGFloat(index)
            let y = (size.height - lineWidth) * CGFloat(vector[index]) + lineWidth / 2
            points.append(CGPoint(x: x, y: y))
        }
        return points
    }
    
    func lineWidth(visualType: CHVisualType) -> CGFloat {
        switch visualType {
            case .outline(_, let lineWidth):
                return lineWidth
            case .filled(_, let lineWidth):
                return lineWidth
            case .customFilled(_, let lineWidth, _):
                return lineWidth
        }
    }
    
}

struct CHMath {
    
    static func norm(_ vector: [Double]) -> [Double] {
        let norm = sqrt(Double(vector.reduce(0) {
            $0 + $1 * $1
        }))
        return norm == 0 ? vector : vector.map { $0 / norm }
    }

    static func stretchOut(_ vector: [Double]) -> [Double] {
        guard let min = vector.min(), let rawMax = vector.max() else {
            return vector
        }
        let max = rawMax - min
        return vector.map { ($0 - min) / (max != 0 ? max : 1) }
    }

    static func stretchIn(_ vector: [Double], offset: Double) -> [Double] {
        guard let max = vector.max() else {
            return vector
        }
        let newMax = max - offset
        return vector.map { $0 * newMax + offset }
    }
    
}
