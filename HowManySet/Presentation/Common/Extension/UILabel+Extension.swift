//
//  UILabel+Extension.swift
//  HowManySet
//
//  Created by MJ Dev on 6/16/25.
//

import UIKit

extension UILabel {
    /**
     UILabel을 초기화하는 편리 생성자입니다.
     
     - Parameters:
       - text: 라벨에 표시할 텍스트
       - textColor: 텍스트 색상
       - font: 텍스트 폰트
       - alignment: 텍스트 정렬 방식
     
     이 생성자를 사용하면 UILabel 인스턴스를 생성하면서
     텍스트, 색상, 폰트, 정렬을 한 번에 설정할 수 있습니다.
     */
    convenience init(text: String,
                     textColor: UIColor,
                     font: UIFont,
                     alignment: NSTextAlignment) {
        self.init()
        self.text = text
        self.textColor = textColor
        self.font = font
        self.textAlignment = alignment
    }
}
