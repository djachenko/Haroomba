//
//  FieldPresenter.swift
//  DromAuto
// 
//  Created by Igor Djachenko on 21.11.2023.
//

import Foundation

protocol GameViewProtocol: AnyObject {
    func set(fieldDimension: Dimension)

    func didUpdate(fieldViewModel: FieldViewModel)
    func didUpdate(brickViewModel: BrickViewModel)
}

protocol GamePresenterInput {
    func viewDidLoad()

    func didTapLeftButton()
    func didTapRightButton()
    func didTapRotateButton()
}

class GamePresenter {
    weak var view: GameViewProtocol?

    var output: TetrisInput?

    private var tetrisParameters: TetrisParameters!
}

extension GamePresenter: TetrisOutput {
    func didUpdate(parameters: TetrisParameters) {
        tetrisParameters = parameters

        DispatchQueue.main.async { [weak self] in
            self?.view?.set(fieldDimension: parameters.fieldDimensions)
        }
    }

    func didUpdate(field: Field) {
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

    func didUpdate(brick: Brick) {
        let viewModel = BrickViewModel(
            origin: CGPoint(
                x: brick.origin.x,
                y: brick.origin.y
            ),
            cellViewModels: brick.points.map { point in
                CellViewModel(
                    x: CGFloat(point.x),
                    y: CGFloat(point.y),
                    color: .green
                )
            }
        )

        DispatchQueue.main.async { [weak self] in
            self?.view?.didUpdate(brickViewModel: viewModel)
        }
    }
}

extension GamePresenter: GamePresenterInput {
    func viewDidLoad() {
        output?.start()
    }

    func didTapLeftButton() {
        output?.move(direction: .left)
    }

    func didTapRightButton() {
        output?.move(direction: .right)
    }

    func didTapRotateButton() {
        output?.rotate()
    }
}