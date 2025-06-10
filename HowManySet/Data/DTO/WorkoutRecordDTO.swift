//
//  WorkoutRecord.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

/// 운동 기록을 나타내는 Realm 객체입니다.
/// 운동 루틴, 총 운동 시간, 실제 운동 시간, 날짜 및 코멘트 정보를 포함합니다.
final class WorkoutRecordDTO: Object {
    /// 기록된 운동 루틴입니다. `WorkoutRoutineDTO` 객체로 저장됩니다.
    @Persisted var workoutRoutine: WorkoutRoutineDTO?

    /// 전체 운동에 소요된 시간(초)입니다.
    @Persisted var totalTime: Int

    /// 실제 운동 수행 시간(초)입니다.
    @Persisted var workoutTime: Int

    /// 해당 운동 기록에 대한 메모 또는 코멘트 (옵션)
    @Persisted var comment: String?

    /// 운동이 수행된 날짜입니다.
    @Persisted var date: Date

    /// 주어진 값들로 `WorkoutRecordDTO` 객체를 초기화합니다.
    /// - Parameters:
    ///   - workoutRoutine: 기록된 운동 루틴
    ///   - totalTime: 전체 운동 시간(초)
    ///   - workoutTime: 실제 운동 시간(초)
    ///   - comment: 운동에 대한 메모 (옵션)
    ///   - date: 운동 수행 날짜
    convenience init(
        workoutRoutine: WorkoutRoutineDTO,
        totalTime: Int,
        workoutTime: Int,
        comment: String? = nil,
        date: Date
    ) {
        self.init()
        self.workoutRoutine = workoutRoutine
        self.totalTime = totalTime
        self.workoutTime = workoutTime
        self.comment = comment
        self.date = date
    }
}

extension WorkoutRecordDTO {
    /// DTO 객체를 도메인 모델 `WorkoutRecord`로 변환합니다.
    /// - Returns: 동일한 정보를 가진 `WorkoutRecord` 도메인 객체
    /// - Note: `workoutRoutine`이 `nil`일 경우, 이름이 "MOCK"인 빈 루틴으로 대체됩니다.
    func toEntity() -> WorkoutRecord {
        return WorkoutRecord(
            workoutRoutine: self.workoutRoutine?.toEntity()
            ?? WorkoutRoutine(name: "MOCK", workouts: [], restTime: 60),
            totalTime: self.totalTime,
            workoutTime: self.workoutTime,
            comment: self.comment,
            date: self.date
        )
    }
}

extension WorkoutRecordDTO {
    /// 도메인 모델 `WorkoutRecord`를 기반으로 `WorkoutRecordDTO`를 초기화합니다.
    /// - Parameter entity: 변환할 `WorkoutRecord` 도메인 객체
    convenience init(entity: WorkoutRecord) {
        self.init()
        self.workoutRoutine = WorkoutRoutineDTO(entity: entity.workoutRoutine)
        self.totalTime = entity.totalTime
        self.workoutTime = entity.workoutTime
        self.comment = entity.comment
        self.date = entity.date
    }
}
