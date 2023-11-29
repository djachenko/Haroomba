//
//  UIView+Extension.swift
//  Haroomba
// 
//  Created by Igor Djachenko on 21.11.2023.
//

import UIKit

extension UIView {
    class func initFromNib<T: UIView>() -> T {
        Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?[0] as! T
    }
}