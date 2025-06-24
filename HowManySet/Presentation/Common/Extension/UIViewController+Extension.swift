//
//  UIViewController+Extension.swift
//  HowManySet
//
//  Created by MJ Dev on 6/24/25.
//

import UIKit
import SnapKit

extension UIViewController {
    // ScrollView 대응을 위해 현재 보여지는 View의 좌상단 x,y값을 입력받음
    func showToast(x: CGFloat, y: CGFloat, message: String) {
        // 띄워져 있는 toast 제거
        if let existingToast = view.viewWithTag(9999) {
            existingToast.removeFromSuperview()
        }
        let toastView = UIView()
        let checkImage: UIImage = .checkIcon
        let imageView = UIImageView(image: checkImage)
        let titleLabel = UILabel()
        
        titleLabel.text = message
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textAlignment = .left
        
        toastView.tag = 9999
        toastView.clipsToBounds = true
        toastView.layer.cornerRadius = 12
        toastView.backgroundColor = .disabledButton
        toastView.addSubviews(imageView, titleLabel)
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
        }
        let padding: CGFloat = 20
        let width: CGFloat = view.frame.width - padding * 2
        let height: CGFloat = 48
        var navBarHeight: CGFloat = 0
        // 하단 SafeArea 높이
        var bottomSafeAreaHeight = view.safeAreaInsets.bottom
        // 네비바 높이
        if let hgt = navigationController?.navigationBar.frame.height {
            navBarHeight = hgt
        }
        
        toastView.frame = CGRect(x: padding,
                                 y: y + UIScreen.main.bounds.height - navBarHeight - bottomSafeAreaHeight - 110,
                                 width: width,
                                 height: height)
        view.addSubview(toastView)
        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
                toastView.alpha = 0
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
    
    func defaultAlert(title: String,
                             message: String) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        return alert
    }
}
