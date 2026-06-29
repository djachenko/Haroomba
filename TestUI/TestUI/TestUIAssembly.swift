//
//  TestUIAssembly.swift
//  TestUI
//
//  Created by justin on 28.11.2023.
//

import UIKit
import Tetris

public final class TestUIAssembly {
    public static let instance = TestUIAssembly()

    public func vc() -> UIViewController {
        let viewController = GameViewController.instance()
        let presenter = GamePresenter()
        viewController.set(presenter: presenter)
        viewController.output = presenter

        let tetris = makeTetrisInput(width: 9, height: 13)
        tetris.set(output: presenter)
        presenter.tetrisInput = tetris

        return viewController
    }
}
