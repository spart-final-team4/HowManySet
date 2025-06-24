//
//  UIViewController+Extension.swift
//  HowManySet
//
//  Created by MJ Dev on 6/24/25.
//

import UIKit
import SnapKit

extension UIViewController {
    func showToast(message: String) {
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
        toastView.frame = CGRect(x: 20,
                                 y: view.frame.maxY - height - 100,
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
