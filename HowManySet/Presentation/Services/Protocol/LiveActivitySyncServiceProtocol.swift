//
//  LiveActivitySyncServiceProtocol.swift
//  HowManySet
//
//  Created by 정근호 on 2025-11-16.
//

import Foundation

/// LiveActivity 동기화 서비스 프로토콜
protocol LiveActivitySyncServiceProtocol {
    /// 동기화 시작 (0.5초마다 폴링)
    /// - Parameter actionHandler: LiveActivity 이벤트 핸들러
    func startSync(actionHandler: @escaping (LiveActivityAction) -> Void)

    /// 동기화 중지
    func stopSync()
}

/// LiveActivity에서 발생한 액션 타입
enum LiveActivityAction {
    case restPauseButtonClicked
    case setCompleteButtonClicked(at: Int)
    case skipRestButtonClicked(at: Int)
}
