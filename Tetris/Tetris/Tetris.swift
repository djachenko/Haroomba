//
//  Tetris.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 21.11.2023.
//

import Foundation

public struct TetrisParameters {
    public var fieldDimensions: Dimensions
}

public protocol TetrisOutput: AnyObject {
    func didUpdate(parameters: TetrisParameters)
    func didUpdate(field: Field)
    func didUpdate(brick: Brick)
    func didUpdate(score: Int)
}

public protocol TetrisInput {
    func set(output: TetrisOutput)

    func start()
    func move(direction: Direction)
    func rotate()
}

final class Tetris {
    private var currentBrick: Brick! // todo: multiple
    private var field: Field

    private var timer: Timer!
    private var factory: BrickFactory

    private var score: Int = 0

    weak var output: TetrisOutput?

    init(brickFactory: BrickFactory, field: Field) {
        factory = brickFactory
        self.field = field
    }

    func runLoop() {
        if field.validate(brick: currentBrick.moved(direction: .down)) {
            move(direction: .down)
        } else {
            if currentBrick.origin.y < 0 {
                stop()
            }

            field.drop(brick: currentBrick)

            output?.didUpdate(field: field)

            getNewBrick()
        }

        let fullRows = field.checkRows()

        if !fullRows.isEmpty {

            fullRows.forEach { i in
                field.drop(row: i)
            }

            score += 2.pow(exp: fullRows.count - 1)

            output?.didUpdate(field: field)
            output?.didUpdate(score: score)
        }
    }

    private func getNewBrick() {
        currentBrick = factory.next()
        currentBrick.origin = Point(x: field.width / 2, y: -2)

        output?.didUpdate(brick: currentBrick)
    }

    func stop() {
        timer.invalidate()
    }
}

extension Tetris: TetrisInput {
    public func set(output: TetrisOutput) {
        self.output = output
    }

    public func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.runLoop()
        }

        output?.didUpdate(parameters: TetrisParameters(
            fieldDimensions: field.dimensions
        ))

        score = 0

        output?.didUpdate(score: score)

        getNewBrick()
    }

    private func update(nextBrick: Brick) {
        guard field.validate(brick: nextBrick) else {
            return
        }

        currentBrick = nextBrick

        output?.didUpdate(brick: nextBrick)
    }

    public func move(direction: Direction) {
        update(nextBrick: currentBrick.moved(direction: direction))
    }

    public func rotate() {
        update(nextBrick: currentBrick.rotated())
    }
}
