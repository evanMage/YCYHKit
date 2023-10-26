//
//  CHLineChart.swift
//  CHLineChart
//
//  Created by evan on 2023/5/29.
//

import SwiftUI

enum CHVisualType {
    case outline(color: Color, lineWidth: CGFloat)
    case filled(color: Color, lineWidth: CGFloat)
    case customFilled(color: Color, lineWidth: CGFloat, fillGradient: LinearGradient)
}

enum CHLineType {
    case line
    case curved
}

struct CHLineChart: View, CHCoreDataProtocol {
    
    /// 节点数据
    private let data: [Double]
    /// 取值范围，最小值和最大值
    private let dataRange: [Double]?
    /// 绘制范围大小
    private let size: CGSize
    /// 绘制折线颜色和线宽
    private let visualType: CHVisualType
    /// 折线样式
    private let lineType: CHLineType
    /// 绘制节点坐标 (转换节点数据)
    private var points = [CGPoint]()
    /// 是否显示结尾圆点
    private var showCricle: Bool
    /// 圆点配置信息
    private var cricleConfig: CHCircleConfig
    
    init(data: [Double], dataRange: [Double]? = nil, size: CGSize, visualType: CHVisualType = .outline(color: .red, lineWidth: 2), lineType: CHLineType = .line, showCricle: Bool = false, cricleConfig: CHCircleConfig = CHCircleConfig()) {
        self.data = data
        self.dataRange = dataRange
        self.size = size
        self.visualType = visualType
        self.lineType = lineType
        self.showCricle = showCricle
        self.cricleConfig = cricleConfig
        self.points = points(forData: data, range: dataRange ?? [], size: size, lineWidth: lineWidth(visualType: visualType))
    }
    
    var body: some View {
        if showCricle {
            ZStack {
                chartView
                    .rotationEffect(.degrees(180), anchor: .center)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
//                    .drawingGroup()
                if points.count > 0 {
                    let lastPoint = points.last!
                    CHCircleView(config: cricleConfig)
                        .position(x: lastPoint.x, y: size.height - lastPoint.y)
                }
            }
        } else {
            chartView
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
//                .drawingGroup()
        }
    }
    
    //MARK: - private methods

    private var chartView: some View {
        
        switch visualType {
        case .outline(let color, let lineWidth):
            return AnyView(
                (lineType == .line ? linePath(points: points) : curvedPath(points: points))
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
            )
        case .filled(let color, let lineWidth):
            return AnyView(
                ZStack {
                    pathGradient(points: points)
                        .fill(LinearGradient(gradient: .init(colors: [color.opacity(0.4), color.opacity(0.02)]), startPoint: .init(x: 0.5, y: 1), endPoint: .init(x: 0.5, y: 0)))
                    (lineType == .line ? linePath(points: points) : curvedPath(points: points))
                        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
                }
            )
        case .customFilled(let color, let lineWidth, let fillGradient):
            return AnyView(
                ZStack {
                    pathGradient(points: points)
                        .fill(fillGradient)
                    (lineType == .line ? linePath(points: points) : curvedPath(points: points))
                        .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
                }
            )
        }
    }
    
    private func linePath(points: [CGPoint]) -> Path {
        let pointArray = nodeProcessing(points: points)
        var path = Path()
        for item in pointArray {
            guard item.count > 1 else {
                return path
            }
            path.move(to: item[0])
            for point in item {
                path.addLine(to: point)
            }
        }
        return path
    }
    
    private func pathGradient(points: [CGPoint]) -> Path {
        var path = lineType == .line ? linePath(points: points) : curvedPath(points: points)
        guard let lastPath = points.last else {
            return path
        }
        path.addLine(to: CGPoint(x: lastPath.x, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: points[0].y))
        return path
    }
    
    private func curvedPath(points: [CGPoint]) -> Path {
        let pointArray = nodeProcessing(points: points)
        func mid(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
            return CGPoint(x: (point1.x + point2.x) / 2, y:(point1.y + point2.y) / 2)
        }
        func control(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
            var controlPoint = mid(point1, point2)
            let delta = abs(point2.y - controlPoint.y)
            if point1.y < point2.y {
                controlPoint.y += delta
            } else if point1.y > point2.y {
                controlPoint.y -= delta
            }
            return controlPoint
        }
        var path = Path()
        for item in pointArray {
            guard item.count > 1 else {
                return path
            }
            var startPoint = item[0]
            path.move(to: startPoint)
            guard points.count > 2 else {
                path.addLine(to: item[1])
                return path
            }
            for index in 1 ..< item.count {
                let currentPoint = item[index]
                let midPoint = mid(startPoint, currentPoint)
                path.addQuadCurve(to: midPoint, control: control(midPoint, startPoint))
                path.addQuadCurve(to: currentPoint, control: control(midPoint, currentPoint))
                startPoint = currentPoint
            }
        }
        return path
    }
    
    private func nodeProcessing(points: [CGPoint]) -> [[CGPoint]] {
        var dataArray: Array<Array<CGPoint>> = []
        var pointArray: Array<CGPoint> = []
        let lineWidth = lineWidth(visualType: visualType)
        for item in points {
            if item.y == lineWidth / 2.0 {
                if pointArray.count > 0 {
                    dataArray.append(pointArray)
                    pointArray.removeAll()
                }
            } else {
                pointArray.append(item)
            }
        }
        if pointArray.count > 0 {
            dataArray.append(pointArray)
        }
        return dataArray
    }
}


struct CHLineChart_Previews: PreviewProvider {
    static var previews: some View {
        CHLineChart(data: [2, 4, 9, 8, 10, 2, 5, 9, 0, 15, 12, 10, 2, 12, 9, 5, 13, 2, 5, 9, 0, 15, 12, 10, 2, 12, 9, 5, 8], dataRange: [-0.01, 15], size: CGSize(width: 180, height: 80), visualType: .outline(color: .purple, lineWidth: 2), showCricle: true)
            .frame(width: 180, height: 80)
            .border(.white)
    }
}

