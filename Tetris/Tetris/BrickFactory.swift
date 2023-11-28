//
//  BrickFactory.swift
//  DromAuto
// 
//  Created by Igor Djachenko on 22.11.2023.
//

import Foundation

class BrickFactory {
    static let I = Brick(
        points: [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 2, y: 0),
            Point(x: 3, y: 0),
        ],
        center: CGPoint(x: 1.5, y: 0.5)
    )

    static let J = Brick(
        points: [
            Point(x: 0, y: 0),
            Point(x: 0, y: 1),
            Point(x: 1, y: 1),
            Point(x: 2, y: 1),
        ],
        center: CGPoint(x: 1, y: 1)
    )

    static let L = Brick(
        points: [
            Point(x: 0, y: 1),
            Point(x: 1, y: 1),
            Point(x: 2, y: 1),
            Point(x: 2, y: 0),
        ],
        center: CGPoint(x: 1, y: 1)
    )

    static let O = Brick(
        points: [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 0, y: 1),
            Point(x: 1, y: 1),
        ],
        center: CGPoint(x: 0.5, y: 0.5)
    )

    static let S = Brick(
        points: [
            Point(x: 0, y: 1),
            Point(x: 1, y: 1),
            Point(x: 1, y: 0),
            Point(x: 2, y: 0),
        ],
        center: CGPoint(x: 1, y: 1)
    )

    static let T = Brick(
        points: [
            Point(x: 0, y: 1),
            Point(x: 1, y: 1),
            Point(x: 2, y: 1),
            Point(x: 1, y: 0),
        ],
        center: CGPoint(x: 1, y: 1)
    )

    static let Z = Brick(
        points: [
            Point(x: 0, y: 0),
            Point(x: 1, y: 0),
            Point(x: 1, y: 1),
            Point(x: 2, y: 0),
        ],
        center: CGPoint(x: 1, y: 1)
    )

    static let prototypes = [
        I, J, L, O, S, T, Z
    ]

    func next() -> Brick {
        BrickFactory.prototypes.randomElement()!.copy()
    }
}
