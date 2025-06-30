//
//  UIFont+Extension.swift
//  HowManySet
//
//  Created by 정근호 on 6/29/25.
//

import UIKit

extension UIFont {
    /// PretendardVariable weight별 적용
    static func pretendard(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let fontName: String
        switch weight {
        case .black:
            fontName = "Pretendard-Black"
        case .heavy: // heavy - ExtraBold
            fontName = "Pretendard-ExtraBold"
        case .bold:
            fontName = "Pretendard-Bold"
        case .semibold:
            fontName = "Pretendard-SemiBold"
        case .medium:
            fontName = "Pretendard-Medium"
        case .regular:
            fontName = "Pretendard-Regular"
        case .light:
            fontName = "Pretendard-Light"
        case .thin:
            fontName = "Pretendard-Thin"
        case .ultraLight:
            fontName = "Pretendard-ExtraLight"
        default:
            fontName = "Pretendard-Regular"
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
    
    /// 폰트 이름들 확인
    static func checkFonts() {
        for family in UIFont.familyNames {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   Name: \(name)")
            }
        }
    }
}
