//
//  Point.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 22.11.2023.
//

import Foundation

public struct Point: Sendable {
    public let x: Int
    public let y: Int

    static let zero = Point(x: 0, y: 0)
}
