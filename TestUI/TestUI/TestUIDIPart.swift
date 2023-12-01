//
//  TestUIDIPart.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 29.11.2023.
//

import DITranquillity
import Tetris

public final class TestUIDIPart: DIPart {
    public class func load(container: DIContainer) {
        container.register { GameViewController.instance() }
            .as(UIViewController.self)
            .as(GameViewProtocol.self)
            .injection { $0.output = $1 }
            .injection { $0.set(presenter: $1) }
            .lifetime(.objectGraph)

        container.register(GamePresenter.init)
            .as(GamePresenterInput.self)
            .as(TetrisOutput.self)
            .injection { $0.tetrisInput = $1 }
            .injection(cycle: true) { $0.view = $1 }
            .lifetime(.objectGraph)
    }
}
