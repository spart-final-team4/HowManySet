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
    
    /// Int 값을 00:00:00 형식의 시:분:초 String으로 나타냄
    /// LiveActivity에서도 사용되어 Target 추가되어 있음
    func toWorkOutTimeLabel() -> String {
        let hour = self / 3600
        let minute = (self % 3600) / 60
        let second = self % 60
        
        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            return String(format: "%02d:%02d", minute, second)
        }
    }

    /// Int 값을 "00분" 형태의 String으로 반환하는 메서드 
    func toMinutesLabel() -> String {
        let minutes = self / 60
        let format = String(localized: "분")
        return String(format: format, minutes)
    }
}
