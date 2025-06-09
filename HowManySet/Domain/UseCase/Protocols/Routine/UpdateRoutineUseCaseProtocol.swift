//
//  UpdateRoutineUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/9/25.
//

import Foundation

/// 운동 루틴을 업데이트하는 유스케이스를 정의한 프로토콜입니다.
/// 비즈니스 로직 계층에서 루틴 수정 작업을 담당합니다.
protocol UpdateRoutineUseCaseProtocol {
    
    /// 특정 사용자의 운동 루틴을 업데이트합니다.
    /// - Parameters:
    ///   - uid: 사용자 식별자
    ///   - item: 업데이트할 운동 루틴
    func execute(uid: String, item: WorkoutRoutine)
}
