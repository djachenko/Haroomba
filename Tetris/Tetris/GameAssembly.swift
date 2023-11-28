//
//  GameAssembly.swift
//  DromAuto
// 
//  Created by Igor Djachenko on 22.11.2023.
//

import Foundation

public class GameAssembly {
    public static let instance = GameAssembly() // todo: move to DI

    private var gameInstance: Tetris!

    private init() {}
    
    public func game() -> Tetris {
        let brickFactory = BrickFactory()

        gameInstance = Tetris(brickFactory: brickFactory, fieldDimensions: Dimensions(width: 9, height: 13))

        return gameInstance
    }
}
