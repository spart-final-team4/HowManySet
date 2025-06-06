//
//  Int+Extension.swift
//  HowManySet
//
//  Created by 정근호 on 6/6/25.
//

import Foundation

extension Int {
    /// Int 값을 00:00 형식의 분:초 String으로 나타냄
    /// LiveActivity에서도 사용되어 Target 추가되어 있음
    func toRestTimeLabel() -> String {
        
        let minute = self / 60
        let seconds = self % 60
        
        return String(format: "%02d:%02d", minute, seconds)
    }
}
