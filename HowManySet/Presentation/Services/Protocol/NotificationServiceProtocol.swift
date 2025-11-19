//
//  NotificationServiceProtocol.swift
//  HowManySet
//
//  Created by 정근호 on 2025-11-16.
//

import Foundation

/// 알림 관리 서비스 프로토콜
/// DIP: 구체 클래스 대신 프로토콜에 의존
protocol NotificationServiceProtocol {
    /// 알림 권한 요청
    func requestNotification()

    /// 휴식 종료 알림 예약
    /// - Parameter seconds: 알림까지 남은 시간(초)
    func scheduleRestFinishedNotification(seconds: TimeInterval)

    /// 휴식 알림 제거
    func removeRestNotification()
}
