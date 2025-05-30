//
//  UIView+Extension.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
    
    /// 원형 테두리 및 그림자 설정
    func setViewCornerRadAndShadow(baseView: UIView, cornerRad: CGFloat, shadowOffset: CGSize, shadowRad: CGFloat, shadowOpacity: Float) {
        baseView.layer.masksToBounds = true
        baseView.layer.cornerRadius = cornerRad
        
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRad
        self.layer.shadowOpacity = shadowOpacity
    }
}
