//
//  Tetris.swift
//  DromAuto
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
}

public protocol TetrisInput {
    func start()
    func move(direction: Direction)
    func rotate()
}

public class Tetris {
    private var currentBrick: Brick! // todo: multiple
    private var field: Field

    private var timer: Timer!
    private var factory: BrickFactory

    private var points: Int = 0

    public var cycle: Any?
    public weak var output: TetrisOutput?

    init(brickFactory: BrickFactory, fieldDimensions: Dimensions) {
        factory = brickFactory

        field = Field(dimensions: fieldDimensions)
    }

    func runLoop() {
        move(direction: .down)

        if !field.validate(brick: currentBrick.moved(direction: .down)) {
            if currentBrick.origin.y < 0 {
                stop()
            }

            field.drop(brick: currentBrick)

            output?.didUpdate(field: field)

            getNewBrick()
        }

        let fullRows = field.checkRows()

        if !fullRows.isEmpty {
            points += 2.pow(exp: fullRows.count - 1)

            fullRows.forEach { i in
                field.drop(row: i)
            }

            output?.didUpdate(field: field)
        }

        print(points)
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
    public func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.runLoop()
        }

        output?.didUpdate(parameters: TetrisParameters(
            fieldDimensions: Dimensions(
                width: field.width,
                height: field.height
            )
        ))

        points = 0

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

extension Int {
    func pow(exp: Int) -> Int {
        Int(Darwin.pow(Double(self), Double(exp)))
    }
}
