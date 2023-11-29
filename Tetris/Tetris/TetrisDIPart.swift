//
//  TetrisDIPart.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 22.11.2023.
//

import Foundation
import DITranquillity

public final class TetrisDIPart: DIPart {
    public class func load(container: DIContainer) {
        container.register(Tetris.init)
            .as(TetrisInput.self)
            .injection(cycle: true) { $0.output = $1 }
            .lifetime(.perContainer(.strong))

        container.register(BrickFactory.init)
            .lifetime(.perContainer(.weak))

        container.register { Field(dimensions: arg($0)) }
    }
}
