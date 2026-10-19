//
//  CellView.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 21.11.2023.
//

import UIKit

struct CellViewModel {
    let x: CGFloat
    let y: CGFloat

    let color: UIColor
}

class CellView: UIView {
    @IBOutlet weak var backgroundView: UIView!

    private var sizeConstraint: NSLayoutConstraint!

    nonisolated override func awakeFromNib() {
        super.awakeFromNib()

//        sizeConstraint = heightAnchor.constraint(equalToConstant: 10)
//
//        NSLayoutConstraint.activate([
//            heightAnchor.constraint(equalTo: widthAnchor),
//            sizeConstraint,
//        ])
//
        MainActor.assumeIsolated {
            translatesAutoresizingMaskIntoConstraints = false
        }
    }

    func configure(cellViewModel: CellViewModel) {
        backgroundColor = cellViewModel.color
    }
}
