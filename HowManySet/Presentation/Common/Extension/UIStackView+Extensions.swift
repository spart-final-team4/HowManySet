//
//  UIStackView+Extensions.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
}
