//
//  Field.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 21.11.2023.
//

import Foundation

public final class Field {
    public private(set) var cells: [[CellModel?]] = []

    public var width: Int {
        dimensions.width
    }

    public var height: Int {
        dimensions.height
    }

    private(set) var dimensions: Dimensions = .zero

    init(dimensions: Dimensions = .zero) {
        self.dimensions = dimensions

        clear()
    }

    private func addEmptyRow() {
        guard cells.count < height else {
            return
        }

        let newRow = [CellModel?](repeating: nil, count: width)

        cells.insert(newRow, at: 0)
    }

    private func removeRow(at index: Int) {
        cells.remove(at: index)
    }

    func drop(brick: Brick) {
        brick.points.forEach { point in
            let pointY = brick.origin.y + point.y
            let pointX = (brick.origin.x + point.x).wrapped(limit: width)

            guard (0..<width) ~= pointX,
                  (0..<height) ~= pointY else {
                return
            }

            return cells[pointY][pointX] = CellModel()
        }
    }

    func validate(brick: Brick) -> Bool {
        brick.points.allSatisfy { point in
            let newX = (brick.origin.x + point.x).wrapped(limit: width)
            let newY = brick.origin.y + point.y

            let canMoveX = (0..<width) ~= newX
            let canMoveY = newY < height

            return canMoveX &&
                canMoveY &&
                cells[max(newY, 0)][newX] == nil
        }
    }

    public func checkRows() -> [Int] {
        var result = [Int]()

        cells.enumerated().forEach { rowIndex, row in
            let isRowFull = row.allSatisfy {
                $0 != nil
            }

            if isRowFull {
                result.append(rowIndex)
            }
        }

        return result
    }

    func drop(row index: Int) {
        removeRow(at: index)
        addEmptyRow()
    }

    func clear() {
        cells = []

        (0..<height).forEach { _ in
            addEmptyRow()
        }
    }
}
