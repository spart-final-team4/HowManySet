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

extension WorkoutRecordDTO {
    init(from fsModel: FSWorkoutRecord) {
        let routine = WorkoutRoutineDTO(
            name: fsModel.workoutRoutineName ?? "Unknown",
            workouts: fsModel.workouts.map { WorkoutDTO(from: $0) }
        )
        
        self.workoutRoutine = routine
        self.totalTime = fsModel.totalTime
        self.workoutTime = fsModel.workoutTime
        self.comment = fsModel.comment
        self.date = fsModel.completedAt
    }
}

extension WorkoutRecordDTO {
    func toFSModel(userId: String) -> FSWorkoutRecord {
        return FSWorkoutRecord(
            workoutRoutineId: nil,
            workoutRoutineName: self.workoutRoutine?.name,
            workouts: self.workoutRoutine?.workouts.map { $0.toFSModel() } ?? [],
            totalTime: self.totalTime,
            workoutTime: self.workoutTime,
            userId: userId,
            comment: self.comment
        )
    }
}

