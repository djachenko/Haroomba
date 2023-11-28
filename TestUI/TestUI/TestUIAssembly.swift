//
//  TestUIAssembly.swift
//  TestUI
//
//  Created by justin on 28.11.2023.
//

import Foundation
import UIKit
import Tetris

public class TestUIAssembly {
    public static let instance = TestUIAssembly()
    
    public func vc() -> UIViewController {
        let viewController = GameViewController.instance()

        let presenter = GamePresenter()
        viewController.set(presenter: presenter)
        viewController.output = presenter

        let tetris = GameAssembly.instance.game()

        tetris.cycle = tetris
        tetris.output = presenter

        presenter.output = tetris
        
        return viewController
    }
}
