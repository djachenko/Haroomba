//
//  TestUIAssembly.swift
//  TestUI
//
//  Created by justin on 28.11.2023.
//

import Foundation
import UIKit
import Tetris
import DITranquillity

public class TestUIAssembly {
    public static let instance = TestUIAssembly()
    
    public func vc() -> UIViewController {
        let viewController = GameViewController.instance()

        let presenter = GamePresenter()
        viewController.set(presenter: presenter)
        viewController.output = presenter

        let container = DIContainer()

        container.append(part: TetrisDIPart.self)

        var args = AnyArguments()
        args.addArgs(for: Field.self, args: Dimensions(width: 9, height: 13))

        let tetris: TetrisInput = container.resolve(arguments: args)

        tetris.set(output: presenter)

        presenter.tetrisInput = tetris
        
        return viewController
    }
}
