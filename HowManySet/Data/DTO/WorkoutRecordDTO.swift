//
//  WorkoutRecord.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

struct WorkoutRecordDTO {
    let id: String
    var workoutRoutine: WorkoutRoutineDTO?
    var totalTime: Int
    var workoutTime: Int
    var comment: String?
    var date: Date
}

extension WorkoutRecordDTO {
    func toEntity() -> WorkoutRecord {
        return WorkoutRecord(
            id: self.id,
            workoutRoutine: self.workoutRoutine?.toEntity()
            ?? WorkoutRoutine(id: "", name: "MOCK", workouts: []),
            totalTime: self.totalTime,
            workoutTime: self.workoutTime,
            comment: self.comment,
            date: self.date
        )
    }
}

extension WorkoutRecordDTO {
    init(entity: WorkoutRecord) {
        self.id = entity.id
        self.workoutRoutine = WorkoutRoutineDTO(entity: entity.workoutRoutine)
        self.totalTime = entity.totalTime
        self.workoutTime = entity.workoutTime
        self.comment = entity.comment
        self.date = entity.date
    }
}

extension WorkoutRecordDTO {
    init(from model: RMWorkoutRecord) {
        self.id = model.id
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
            // TODO: 검토 필요
            id: fsModel.id ?? "",
            name: fsModel.workoutRoutineName ?? "Unknown",
            workouts: fsModel.workouts.map { WorkoutDTO(from: $0) }
        )
        self.id = routine.id
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

