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
    func drop()
    func playPause()
}

final class Tetris {
    private enum State {
        case stopped
        case paused
        case playing
    }

    private var currentBrick: Brick! // todo: multiple
    private var field: Field

    private var timer: Timer?
    private var state: State = .stopped
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
                stopGame()
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
}

private extension Tetris {
    private func updateTimer(state: State) {
        switch state {

        case .stopped, .paused:
            timer?.invalidate()
            timer = nil
        case .playing:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                self.runLoop()
            }
        }
    }

    func stopGame() {
        state = .stopped

        updateTimer(state: state)
    }

    func unpauseGame() {
        state = .playing

        updateTimer(state: state)
    }

    func pauseGame() {
        guard state == .playing else {
            return
        }

        state = .paused

        updateTimer(state: state)
    }

    func startGame() {
        guard state == .stopped else {
            return
        }

        score = 0
        field.clear()

        output?.didUpdate(score: score)
        output?.didUpdate(field: field)

        getNewBrick()

        state = .paused
        unpauseGame()
    }
}

public func makeTetrisInput(width: Int = 9, height: Int = 13) -> TetrisInput {
    let field = Field(dimensions: Dimensions(width: width, height: height))
    return Tetris(brickFactory: BrickFactory(), field: field)
}

extension Tetris: TetrisInput {
    public func set(output: TetrisOutput) {
        self.output = output
    }

    public func start() {
        output?.didUpdate(parameters: TetrisParameters(
            fieldDimensions: field.dimensions
        ))

        startGame()
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

    public func drop() {
        while field.validate(brick: currentBrick.moved(direction: .down)) {
            move(direction: .down)
        }

        field.drop(brick: currentBrick)

        output?.didUpdate(field: field)
    }

    public func playPause() {
        switch state {
        case .stopped:
            startGame()
        case .paused:
            unpauseGame()
        case .playing:
            pauseGame()
        }
    }
}
