//
//  LiveActivityServiceProtocol.swift
//  HowManySet
//
//  Created by 정근호 on 2025-11-16.
//

import Foundation
import ActivityKit

/// LiveActivity 관리 서비스 프로토콜
protocol LiveActivityServiceProtocol {
    /// LiveActivity 시작
    /// - Parameter data: 운동 데이터
    func start(with data: WorkoutDataForLiveActivity)

    /// LiveActivity 상태 업데이트
    /// - Parameter state: 새로운 상태
    func update(state: HowManySetWidgetAttributes.ContentState)

    /// LiveActivity 종료
    func stop()
}
