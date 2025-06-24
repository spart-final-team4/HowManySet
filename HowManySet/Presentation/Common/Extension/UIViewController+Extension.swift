//
//  UIViewController+Extension.swift
//  HowManySet
//
//  Created by MJ Dev on 6/24/25.
//

import UIKit

extension UIViewController {
    func showToast(message: String) {
        // 띄워져 있는 toast 제거
        if let existingToast = view.viewWithTag(9999) {
            existingToast.removeFromSuperview()
        }
        let toast = UILabel()
        toast.tag = 9999
        toast.text = message
        toast.textColor = .systemBackground
        toast.backgroundColor = UIColor.separator.withAlphaComponent(0.8)
        toast.textAlignment = .center
        toast.font = .systemFont(ofSize: 14, weight: .bold)
        toast.alpha = 0
        toast.clipsToBounds = true
        toast.numberOfLines = 0
        let padding: CGFloat = 20
        let maxWidth = (view.frame.width - padding * 2) / 2
        let size = toast.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        toast.frame = CGRect(x: view.frame.width/2 - (maxWidth/2),
                             y: view.frame.maxY - size.height - 100,
                             width: maxWidth,
                             height: size.height + 16)
        toast.layer.cornerRadius = toast.frame.height / 2
        view.addSubview(toast)
        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
                toast.alpha = 0
            }) { _ in
                toast.removeFromSuperview()
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
