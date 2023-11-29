//
//  Extensions.swift
//  DromAuto
// 
//  Created by Igor Djachenko on 29.11.2023.
//

import Foundation

public extension Int {
    func wrapped(limit: Int) -> Int {
        var selfCopy = self

        while !((0..<limit) ~= selfCopy) {
            if selfCopy < 0 {
                selfCopy += limit
            } else {
                selfCopy -= limit
            }
        }

        return selfCopy
    }
}

extension Int {
    func pow(exp: Int) -> Int {
        Int(Darwin.pow(Double(self), Double(exp)))
    }
}