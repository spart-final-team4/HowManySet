//
//  WorkoutRecord.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

struct WorkoutRecordDTO {
    var workoutRoutine: WorkoutRoutineDTO?
    var totalTime: Int
    var workoutTime: Int
    var comment: String?
    var date: Date
}

extension WorkoutRecordDTO {
    func toEntity() -> WorkoutRecord {
        return WorkoutRecord(
            workoutRoutine: self.workoutRoutine?.toEntity()
            ?? WorkoutRoutine(name: "MOCK", workouts: []),
            totalTime: self.totalTime,
            workoutTime: self.workoutTime,
            comment: self.comment,
            date: self.date
        )
    }
}

extension WorkoutRecordDTO {
    init(entity: WorkoutRecord) {
        self.workoutRoutine = WorkoutRoutineDTO(entity: entity.workoutRoutine)
        self.totalTime = entity.totalTime
        self.workoutTime = entity.workoutTime
        self.comment = entity.comment
        self.date = entity.date
    }
}

extension WorkoutRecordDTO {
    init(from model: RMWorkoutRecord) {
        self.workoutRoutine = model.workoutRoutine?.toDTO()
        self.totalTime = model.totalTime
        self.workoutTime = model.workoutTime
        self.comment = model.comment
        self.date = model.date
    }
}
