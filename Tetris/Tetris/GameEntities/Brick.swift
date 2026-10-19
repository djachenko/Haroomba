//
//  Brick.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 21.11.2023.
//

import Foundation

public struct Brick: Sendable {
    public internal(set) var origin: Point
    public let points: [Point]
    public let center: CGPoint

    init(points: [Point], center: CGPoint, origin: Point = .zero) {
        self.points = points
        self.center = center
        self.origin = origin
    }
}

extension Brick {
    func rotated() -> Brick {
        let alpha: Double = .pi / 2

        let sinA = sin(alpha)
        let cosA = cos(alpha)

        let newPoints = points.map { point in
            let dx = Double(point.x) - center.x
            let dy = Double(point.y) - center.y

            let x = center.x + dx * cosA - dy * sinA
            let y = center.y + dx * sinA + dy * cosA

            return Point(
                x: Int(round(x)),
                y: Int(round(y))
            )
        }

        return Brick(
            points: newPoints,
            center: center,
            origin: origin
        )
    }

    func moved(direction: Direction) -> Brick {
        Brick(
            points: points,
            center: center,
            origin: Point(
                x: origin.x + direction.dx,
                y: origin.y + direction.dy
            )
        )
    }
}
