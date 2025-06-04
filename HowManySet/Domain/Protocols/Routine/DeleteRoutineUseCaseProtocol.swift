//
//  DeleteRoutineUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/2/25.
//

import Foundation

/// 운동 루틴을 삭제하는 유스케이스 프로토콜입니다.
///
/// 특정 사용자의 운동 루틴을 삭제하는 기능을 정의합니다.
protocol DeleteRoutineUseCaseProtocol {
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 삭제합니다.
    ///
    /// - Parameters:
    ///   - uid: 운동 루틴을 삭제할 사용자의 고유 식별자
    ///   - item: 삭제할 `WorkoutRoutine` 객체
    func execute(uid: String, item: WorkoutRoutine)
}
