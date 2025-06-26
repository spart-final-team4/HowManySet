//
//  LoadingIndicator.swift
//  HowManySet
//
//  Created by GO on 6/26/25.
//

import UIKit

final class LoadingIndicator {
    
    /// 로딩 인디케이터 표시
    static func showLoadingIndicator() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return
            }
            
            // 이미 있으면 중복 방지
            if window.subviews.contains(where: { $0 is UIActivityIndicatorView }) {
                return
            }
            
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .white
            indicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            indicator.frame = window.bounds
            indicator.startAnimating()
            
            window.addSubview(indicator)
        }
    }
    
    /// 로딩 인디케이터 숨김
    static func hideLoadingIndicator() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                return
            }
            
            window.subviews
                .compactMap { $0 as? UIActivityIndicatorView }
                .forEach { $0.removeFromSuperview() }
        }
    }
}
