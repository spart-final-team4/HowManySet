//
//  WorkoutRoutineDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation

/// 운동 루틴 정보를 전송하거나 저장할 때 사용하는 데이터 전송 객체(Data Transfer Object)입니다.
///
/// 루틴 이름과 그에 포함된 운동 목록을 담고 있으며, 네트워크 또는 저장소 계층에서 사용됩니다.
struct WorkoutRoutineDTO {
    
    /// 운동 루틴의 이름입니다.
    ///
    /// 예: `"하체 루틴"`, `"상체 집중 루틴"` 등
    let name: String
    
    /// 루틴에 포함된 운동 목록입니다.
    ///
    /// 각 요소는 `WorkoutDTO` 타입이며, 루틴을 구성하는 개별 운동을 나타냅니다.
    let workouts: [WorkoutDTO]
    
    /// 세트 간의 휴식 시간(초)입니다.
    ///
    /// 예: `60`이면 세트 간 휴식 시간이 60초입니다.
    let restTime: Int
}

extension WorkoutRoutineDTO {
    
    /// DTO를 도메인 모델인 `WorkoutRoutine` 객체로 변환합니다.
    ///
    /// - Returns: `WorkoutRoutine` 타입의 도메인 모델 인스턴스
    func toEntity() -> WorkoutRoutine {
        return WorkoutRoutine(name: self.name,
                              workouts: self.workouts.map { $0.toEntity() }, restTime: self.restTime)
    }
}

