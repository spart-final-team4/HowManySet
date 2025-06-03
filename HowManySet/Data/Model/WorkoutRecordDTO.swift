//
//  WorkoutRecord.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation

struct WorkoutRecordDTO {
    let workoutRoutine: WorkoutRoutineDTO
    let totalTime: Int
    let workoutTime: Int
    let comment: String?
    let date: Date
}

extension WorkoutRecordDTO {
    func toEntity() -> WorkoutRecord {
        return WorkoutRecord(workoutRoutine: self.workoutRoutine.toEntity(),
                             totalTime: self.totalTime,
                             workoutTime: self.workoutTime,
                             comment: self.comment,
                             date: self.date)
    }
}
