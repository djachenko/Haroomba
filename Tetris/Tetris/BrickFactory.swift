//
//  BrickFactory.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 22.11.2023.
//

import Foundation

final class BrickFactory {
    private static let I = Brick(
        points: [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 2, y: 0),
            Point(x: 3, y: 0),
        ],
        center: CGPoint(x: 1.5, y: 0.5)
    )

    private static let J = Brick(
        points: [
            Point(x: 0, y: 0),
            Point(x: 0, y: 1),
            Point(x: 1, y: 1),
            Point(x: 2, y: 1),
        ],
        center: CGPoint(x: 1, y: 1)
    )

    private static let L = Brick(
        points: [
            Point(x: 0, y: 1),
            Point(x: 1, y: 1),
            Point(x: 2, y: 1),
            Point(x: 2, y: 0),
        ],
        center: CGPoint(x: 1, y: 1)
    )

    private static let O = Brick(
        points: [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 0, y: 1),
            Point(x: 1, y: 1),
        ],
        center: CGPoint(x: 0.5, y: 0.5)
    )

    private static let S = Brick(
        points: [
            Point(x: 0, y: 1),
            Point(x: 1, y: 1),
            Point(x: 1, y: 0),
            Point(x: 2, y: 0),
        ],
        center: CGPoint(x: 1, y: 1)
    )

    private static let T = Brick(
        points: [
            Point(x: 0, y: 1),
            Point(x: 1, y: 1),
            Point(x: 2, y: 1),
            Point(x: 1, y: 0),
        ],
        center: CGPoint(x: 1, y: 1)
    )

    private static let Z = Brick(
        points: [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 1, y: 1),
            Point(x: 2, y: 0),
        ],
        center: CGPoint(x: 1, y: 1)
    )

    private static let prototypes = [
        I, J, L, O, S, T, Z
    ]

    func next() -> Brick {
        BrickFactory.prototypes.randomElement()!
    }
}
