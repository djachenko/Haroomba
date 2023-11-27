//
//  FieldView.swift
//  DromAuto
// 
//  Created by Igor Djachenko on 22.11.2023.
//

import UIKit

struct FieldViewModel {
    let cells: [CellViewModel]
}

class FieldView: UIView {
    private var cellsCache = [CellView]()

    private var ratioConstraint: NSLayoutConstraint!

    private(set) var cellSize: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        ratioConstraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7)

        NSLayoutConstraint.activate([
            ratioConstraint,
        ])
    }

    func set(dimension: Dimension) {
        let ratio = CGFloat(dimension.ratio)

        if ratio != ratioConstraint.multiplier {
            removeConstraint(ratioConstraint)

            ratioConstraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio)

            NSLayoutConstraint.activate([
                ratioConstraint,
            ])
        }

        cellSize = frame.width / CGFloat(dimension.width)
    }

    func configure(viewModel: FieldViewModel) {
        subviews.forEach {
            $0.removeFromSuperview()
            
            if let cellView = $0 as? CellView {
                cellsCache.append(cellView)
            }
        }


        viewModel.cells.forEach { cellViewModel in
            let cellView = cellsCache.popLast() ?? CellView.initFromNib()

            cellView.frame = CGRect(
                x: cellViewModel.x * cellSize,
                y: cellViewModel.y * cellSize,
                width: cellSize,
                height: cellSize
            )

            cellView.configure(cellViewModel: cellViewModel)

            addSubview(cellView)
        }
    }
}
