//
//  UIFont+Extension.swift
//  HowManySet
//
//  Created by 정근호 on 6/29/25.
//

import UIKit

extension UIFont {
    /// PretendardVariable.ttf Font 적용
    static func pretendard(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        if let descriptor = UIFontDescriptor(name: "PretendardVariable", size: size)
            .withSymbolicTraits([]) {
            let traits: [UIFontDescriptor.TraitKey: Any] = [.weight: weight]
            let newDescriptor = descriptor.addingAttributes([.traits: traits])
            return UIFont(descriptor: newDescriptor, size: size)
        }
        
        // 적용된 폰트 이름들 확인 (Family: Academy Engraved LET -> 기본 폰트)
        for family in UIFont.familyNames {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   Name: \(name)")
            }
        }
        
        return UIFont(name: "PretendardVariable", size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
