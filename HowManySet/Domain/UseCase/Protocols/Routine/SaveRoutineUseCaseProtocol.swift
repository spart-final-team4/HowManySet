//
//  SaveRoutineUseCaseProtocol.swift
//  HowManySet
//
//  Created by MJ Dev on 6/2/25.
//

import Foundation

/// 운동 루틴을 저장하는 유스케이스 프로토콜입니다.
///
/// 특정 사용자의 운동 루틴을 저장하는 기능을 정의합니다.
protocol SaveRoutineUseCaseProtocol {
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 저장합니다.
    ///
    /// - Parameters:
    ///   - item: 저장할 `WorkoutRoutine` 객체
    func execute(uid: String?, item: WorkoutRoutine)
}
