//
//  GameAssembly.swift
//  DromAuto
// 
//  Created by Igor Djachenko on 22.11.2023.
//

import Foundation

class GameAssembly {
    func game() -> Tetris {
        let brickFactory = BrickFactory()

        let game = Tetris(brickFactory: brickFactory, fieldDimensions: Dimension(width: 9, height: 13))

        return game
    }
}
