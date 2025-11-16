//
//  WorkoutTimerServiceProtocol.swift
//  HowManySet
//
//  Created by 정근호 on 2025-11-16.
//

import Foundation
import RxSwift

/// 운동 타이머 관리 서비스 프로토콜
protocol WorkoutTimerServiceProtocol {
    /// 운동 시간 타이머 Observable 생성
    /// - Parameter isWorkingout: 운동 중 여부
    /// - Parameter isPaused: 일시정지 상태
    /// - Returns: 1초마다 방출되는 타이머 Observable
    func makeWorkoutTimer(
        isWorkingout: Observable<Bool>,
        isPaused: Observable<Bool>
    ) -> Observable<Void>

    /// 휴식 시간 타이머 Observable 생성
    /// - Parameters:
    ///   - isResting: 휴식 중 여부
    ///   - isRestPaused: 휴식 일시정지 여부
    ///   - isRestTimerStopped: 휴식 타이머 중단 여부
    /// - Returns: 50ms마다 방출되는 타이머 Observable
    func makeRestTimer(
        isResting: Observable<Bool>,
        isRestPaused: Observable<Bool>,
        isRestTimerStopped: Observable<Bool>
    ) -> Observable<Void>
}
