//
//  UIStackView+Extensions.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import UIKit

extension UIStackView {
    /// 여러 개의 뷰를 한 번에 `arrangedSubviews`에 추가합니다.
    /// - Parameter views: 추가할 UIView 인스턴스들을 가변 인자로 받습니다.
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
    
    /// 스택뷰 내 하위 뷰들의 크기를 일괄적으로 설정합니다.
    ///
    /// - 첫 번째와 마지막 뷰는 너비와 높이를 40으로 고정합니다.
    /// - 그 외의 뷰들은 너비를 90, 높이를 40으로 설정합니다.
    ///
    /// 이 메서드는 스택뷰에 서브뷰가 존재할 때만 동작하며,
    /// SnapKit을 사용하여 제약 조건을 설정합니다.
    func configureContentLayoutArrangeSubViews() {
        if subviews.isEmpty { return }
        for i in 0..<subviews.count {
            if i == 0 || i == subviews.count - 1 {
                subviews[i].snp.makeConstraints {
                    $0.width.height.equalTo(40)
                }
            } else {
                subviews[i].snp.makeConstraints {
                    $0.width.equalTo(90)
                    $0.height.equalTo(40)
                }
            }
        }
    }
}
