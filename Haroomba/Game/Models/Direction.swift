//
//  Direction.swift
//  DromAuto
// 
//  Created by Igor Djachenko on 21.11.2023.
//

import Foundation

struct Direction {
    let dx: Int
    let dy: Int

    static let down = Direction(dx: 0, dy: 1)
    static let left = Direction(dx: -1, dy: 0)
    static let right = Direction(dx: 1, dy: 0)

    private init(dx: Int, dy: Int) {
        self.dx = dx
        self.dy = dy
    }
}
