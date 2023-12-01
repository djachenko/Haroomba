//
//  GamePresenter.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 21.11.2023.
//

import Tetris
import CoreGraphics

typealias ScoreViewModel = Int

protocol GameViewProtocol: AnyObject {
    func set(fieldDimension: Dimensions)

    func didUpdate(fieldViewModel: FieldViewModel)
    func didUpdate(brickViewModel: BrickViewModel)
    func didUpdate(scoreViewModel: ScoreViewModel)
}

public protocol GamePresenterInput {
    func viewDidLoad()

    func didTapLeftButton()
    func didTapRightButton()
    func didTapRotateButton()
    func didTapDropButton()
    func didTapPauseButton()
}

public class GamePresenter {
    weak var view: GameViewProtocol?

    public var tetrisInput: TetrisInput?

    private var tetrisParameters: TetrisParameters!
}

extension GamePresenter: TetrisOutput {
    public func didUpdate(parameters: TetrisParameters) {
        tetrisParameters = parameters

        DispatchQueue.main.async { [weak self] in
            self?.view?.set(fieldDimension: parameters.fieldDimensions)
        }
    }

    public func didUpdate(field: Field) {
        var cellModels = [CellViewModel]()

        field.cells.enumerated().forEach { y, row in
            row.enumerated().forEach { x, cell in
                guard cell != nil else {
                    return
                }

                cellModels.append(CellViewModel(
                    x: CGFloat(x),
                    y: CGFloat(y),
                    color: .gray
                ))
            }
        }

        let viewModel = FieldViewModel(
            cells: cellModels
        )

        DispatchQueue.main.async { [weak self] in
            self?.view?.didUpdate(fieldViewModel: viewModel)
        }
    }

    public func didUpdate(brick: Brick) {
        let width = tetrisParameters.fieldDimensions.width

        let viewModel = BrickViewModel(
            cellViewModels: brick.points.map { point in
                CellViewModel(
                    x: CGFloat((point.x + brick.origin.x).wrapped(limit: width)),
                    y: CGFloat(point.y + brick.origin.y),
                    color: .green
                )
            }
        )

        DispatchQueue.main.async { [weak self] in
            self?.view?.didUpdate(brickViewModel: viewModel)
        }
    }

    public func didUpdate(score: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.didUpdate(scoreViewModel: score)
        }
    }
}

extension GamePresenter: GamePresenterInput {
    public func viewDidLoad() {
        tetrisInput?.start()
    }

    public func didTapLeftButton() {
        tetrisInput?.move(direction: .left)
    }

    public func didTapRightButton() {
        tetrisInput?.move(direction: .right)
    }

    public func didTapRotateButton() {
        tetrisInput?.rotate()
    }

    public func didTapDropButton() {
        tetrisInput?.drop()
    }

    public func didTapPauseButton() {
        tetrisInput?.playPause()
    }
}
