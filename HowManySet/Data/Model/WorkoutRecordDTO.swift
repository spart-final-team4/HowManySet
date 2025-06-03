//
//  WorkoutRecord.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation

/// 운동 기록 정보를 전송하거나 저장할 때 사용하는 데이터 전송 객체(Data Transfer Object)입니다.
///
/// 운동 루틴, 수행 시간, 날짜, 코멘트 등 운동 기록과 관련된 정보를 담고 있으며,
/// 네트워크 통신이나 로컬 저장소에서 도메인 모델로 변환하기 위한 중간 계층으로 사용됩니다.
struct WorkoutRecordDTO {
    
    /// 수행한 운동 루틴 정보입니다.
    ///
    /// `WorkoutRoutineDTO` 타입으로, 해당 기록이 어떤 루틴을 기반으로 했는지 나타냅니다.
    let workoutRoutine: WorkoutRoutineDTO
    
    /// 전체 운동 소요 시간(초)입니다.
    ///
    /// 준비 시간 및 휴식 시간을 포함한 전체 세션 시간입니다.
    let totalTime: Int
    
    /// 실제 운동 수행 시간(초)입니다.
    ///
    /// 세트 수행 시간만 포함됩니다.
    let workoutTime: Int
    
    /// 운동에 대한 선택적 메모입니다.
    ///
    /// 예: `"컨디션 좋았음"`, `"무게 증가 시도"` 등
    let comment: String?
    
    /// 운동을 수행한 날짜입니다.
    ///
    /// 운동이 기록된 날짜와 시간입니다.
    let date: Date
}

extension WorkoutRecordDTO {
    
    /// DTO를 도메인 모델인 `WorkoutRecord` 객체로 변환합니다.
    ///
    /// - Returns: `WorkoutRecord` 타입의 도메인 모델 인스턴스
    func toEntity() -> WorkoutRecord {
        return WorkoutRecord(workoutRoutine: self.workoutRoutine.toEntity(),
                             totalTime: self.totalTime,
                             workoutTime: self.workoutTime,
                             comment: self.comment,
                             date: self.date)
    }
}
