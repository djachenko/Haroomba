//
//  HaroombaAssembler.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 29.11.2023.
//

import Foundation
import DITranquillity
import Tetris
import TestUI

class HaroombaAssembler {
    func assemble() -> GameViewController {
        let container = DIContainer()

        container.append(part: TetrisDIPart.self)
        container.append(part: TestUIDIPart.self)

        var args = AnyArguments()
        args.addArgs(for: Field.self, args: Dimensions(width: 9, height: 13))

        return container.resolve(arguments: args)
    }
}
