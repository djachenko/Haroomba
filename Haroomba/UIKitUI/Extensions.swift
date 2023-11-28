//
//  Extensions.swift
//  DromAuto
// 
//  Created by Igor Djachenko on 22.11.2023.
//

import UIKit
import Tetris

extension Dimensions {
    var ratio: Double {
        Double(width) / Double(height)
    }
}

extension UIView {
    func innerInit() {
        let nibName = String(describing: type(of: self))

        guard let nibRoot = UIView.fromXib(name: nibName) else {
            return
        }

        bounds = nibRoot.bounds
        frame = nibRoot.frame
        isOpaque = nibRoot.isOpaque

        addSubview(nibRoot)

        nibRoot.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        nibRoot.translatesAutoresizingMaskIntoConstraints = true
    }

    static func fromXib() -> Self? {
        return fromXib(name: String(describing: self)) as? Self
    }

    static func fromXib(name: String) -> UIView? {
        let loaded = Bundle.main.loadNibNamed(name, owner: nil)!

        let viewArray = loaded.filter({item in
            return item is UIView
        }) as! [UIView]

        return viewArray.first
    }
}