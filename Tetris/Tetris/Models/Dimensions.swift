//
//  Size.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 22.11.2023.
//

import Foundation

public struct Dimensions {
    public let width: Int
    public let height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    static let zero = Dimensions(width: 0, height: 0)
}
