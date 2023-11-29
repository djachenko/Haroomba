//
//  GamePresenter.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 21.11.2023.
//

import Tetris
import CoreGraphics

protocol GameViewProtocol: AnyObject {
    func set(fieldDimension: Dimensions)

    func didUpdate(fieldViewModel: FieldViewModel)
    func didUpdate(brickViewModel: BrickViewModel)
}

public protocol GamePresenterInput {
    func viewDidLoad()

    func didTapLeftButton()
    func didTapRightButton()
    func didTapRotateButton()
}

public class GamePresenter {
    weak var view: GameViewProtocol?

    public var tetrisInput: TetrisInput?
//    {
//        didSet {
//            tetrisInput?.set(output: self)
//        }
//    }

    private var tetrisParameters: TetrisParameters!

    init() {
        print("gp init")
    }
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
}
