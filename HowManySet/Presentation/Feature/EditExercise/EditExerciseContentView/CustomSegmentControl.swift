//
//  CustomSegmentControl.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import UIKit

/// 사용자 정의 스타일의 `UISegmentedControl`.
///
/// 기본 배경색, 선택된 세그먼트 색상, 선택 상태에 따른 폰트 및 색상 설정이 적용됩니다.
/// 세그먼트는 둥근 모서리를 가지며, 선택된 영역은 흰색으로 강조됩니다.
final class CustomSegmentControl: UISegmentedControl {
    
    /// 지정된 타이틀 배열을 기반으로 세그먼트 컨트롤을 초기화합니다.
    ///
    /// - Parameter titles: 각 세그먼트에 표시할 문자열 배열입니다.
    convenience init(titles: [String]) {
        self.init(items: titles)
        selectedSegmentIndex = 0
        backgroundColor = .cardBackground
        selectedSegmentTintColor = .white

        // 선택된 세그먼트의 텍스트 스타일
        setTitleTextAttributes([
            .foregroundColor: UIColor.cardBackground,
            .font: UIFont.pretendard(size: 16, weight: .semibold)
        ], for: .selected)

        // 기본(선택되지 않은) 세그먼트의 텍스트 스타일
        setTitleTextAttributes([
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.pretendard(size: 16, weight: .regular)
        ], for: .normal)
    }

    /// 뷰의 레이아웃이 변경될 때 호출되며, 선택된 세그먼트의 배경 모양을 조정합니다.
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        
        // 선택된 세그먼트에 해당하는 포그라운드 이미지 설정
        let foregroundIndex = numberOfSegments
        if subviews.indices.contains(foregroundIndex),
           let foregroundImageView = subviews[foregroundIndex] as? UIImageView {
            foregroundImageView.bounds = foregroundImageView.bounds.insetBy(
                dx: CGFloat(foregroundIndex),
                dy: CGFloat(foregroundIndex)
            )
            foregroundImageView.image = UIImage(color: .white)
            foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")
            foregroundImageView.layer.masksToBounds = true
            foregroundImageView.layer.cornerRadius = foregroundImageView.bounds.height / 2
        }
    }
}

/// 단색 이미지 생성을 위한 `UIImage` 확장입니다.
extension UIImage {
    /// 지정한 색상과 크기를 가진 이미지 객체를 생성합니다.
    ///
    /// - Parameters:
    ///   - color: 이미지에 사용할 색상입니다.
    ///   - size: 이미지의 크기. 기본값은 `1x1`입니다.
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
