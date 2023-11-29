//
//  GameViewController.swift
//  Haroomba
//
//  Created by justin on 21.11.2023.
//

import UIKit
import Tetris

public class GameViewController: UIViewController {
    private enum Constants {
        static let rowCount: CGFloat = 13
        static let columnCount: CGFloat = 9
    }

    @IBOutlet private var field: FieldView!
    @IBOutlet private var brick: BrickView!

    var presenter: Any!
    var output: GamePresenterInput?

    public func set(presenter: GamePresenter) {
        self.presenter = presenter

//        presenter.view = self
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        output?.viewDidLoad()
    }

    @IBAction private func didTapLeftButton() {
        output?.didTapLeftButton()
    }

    @IBAction private func didTapRightButton() {
        output?.didTapRightButton()
    }

    @IBAction private func didTapRotateButton() {
        output?.didTapRotateButton()
    }
}

extension GameViewController: GameViewProtocol {
    func set(fieldDimension: Dimensions) {
        field.set(dimension: fieldDimension)

        brick.set(cellSize: field.frame.width / CGFloat(fieldDimension.width))
    }

    func didUpdate(fieldViewModel: FieldViewModel) {
        field.configure(viewModel: fieldViewModel)
    }

    func didUpdate(brickViewModel: BrickViewModel) {
        brick.configure(viewModel: brickViewModel)
    }
}

