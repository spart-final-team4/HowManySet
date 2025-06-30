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
    
    /// 스크린샷 캡쳐용
    func asImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

    /// tap했을 때 애니메이션 적용하는 메서드
    func animateTap(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = .identity
            }, completion: { _ in
                completion?()
            })
        }
    }
}
