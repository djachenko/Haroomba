//
//  BrickView.swift
//  DromAuto
// 
//  Created by Igor Djachenko on 22.11.2023.
//

import UIKit

struct BrickViewModel {
    let origin: CGPoint
    let cellViewModels: [CellViewModel]
}

private struct CellPoint {
    let cell: CellView

    let topConstraint: NSLayoutConstraint
    let leadingConstraint: NSLayoutConstraint
}

class BrickView: UIView {
    private var subcells: [CellView] = (0..<4).map { _ in
        .initFromNib()
    }

    private var cellSize: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        subcells.forEach {
            addSubview($0)
        }
    }

    func set(cellSize: CGFloat) {
        self.cellSize = cellSize

        subcells.forEach {
            $0.set(cellSize: cellSize)
        }
    }

    func configure(viewModel: BrickViewModel) {
        (0..<4).forEach { i in
            let cellViewModel = viewModel.cellViewModels[i]
            let cellView = subcells[i]

            cellView.frame = CGRect(
                x: cellViewModel.x * cellSize,
                y: cellViewModel.y * cellSize,
                width: cellSize,
                height: cellSize
            )

            cellView.configure(cellViewModel: cellViewModel)
        }

        frame.size = CGSize(
            width: subcells.map { $0.frame.origin.x + $0.frame.width}.max() ?? 0,
            height: subcells.map { $0.frame.origin.y + $0.frame.width}.max() ?? 0
        )

        frame.origin = CGPoint(
            x: viewModel.origin.x * cellSize,
            y: viewModel.origin.y * cellSize
        )
    }
}
