//
//  Direction.swift
//  DromAuto
// 
//  Created by Igor Djachenko on 21.11.2023.
//

import Foundation

public struct Direction {
    let dx: Int
    let dy: Int

    public static let down = Direction(dx: 0, dy: 1)
    public static let left = Direction(dx: -1, dy: 0)
    public static let right = Direction(dx: 1, dy: 0)

    private init(dx: Int, dy: Int) {
        self.dx = dx
        self.dy = dy
    }
}
