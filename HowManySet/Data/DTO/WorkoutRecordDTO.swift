//
//  WorkoutRecord.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

struct WorkoutRecordDTO {
    let rmID: String
    let documentID: String
    let uuid: String
    var workoutRoutine: WorkoutRoutineDTO?
    var totalTime: Int
    var workoutTime: Int
    var comment: String?
    var date: Date
}

extension WorkoutRecordDTO {
    func toEntity() -> WorkoutRecord {
        return WorkoutRecord(
            rmID: self.rmID,
            documentID: self.documentID,
            uuid: self.uuid,
            workoutRoutine: self.workoutRoutine?.toEntity()
            ?? WorkoutRoutine(rmID: "",
                              documentID: "",
                              name: "MOCK",
                              workouts: []),
            totalTime: self.totalTime,
            workoutTime: self.workoutTime,
            comment: self.comment,
            date: self.date
        )
    }
}

extension WorkoutRecordDTO {
    init(entity: WorkoutRecord) {
        self.rmID = entity.rmID
        self.documentID = entity.documentID
        self.uuid = entity.uuid
        self.workoutRoutine = WorkoutRoutineDTO(entity: entity.workoutRoutine)
        self.totalTime = entity.totalTime
        self.workoutTime = entity.workoutTime
        self.comment = entity.comment
        self.date = entity.date
    }
}

extension WorkoutRecordDTO {
    init(from model: RMWorkoutRecord) {
        self.rmID = model.id
        self.documentID = ""
        self.uuid = ""
        self.workoutRoutine = RMWorkoutRecord.fromRoutineText(model.routineRecordText)
        self.totalTime = model.totalTime
        self.workoutTime = model.workoutTime
        self.comment = model.comment
        self.date = model.date
    }
}

extension WorkoutRecordDTO {
    init(from fsModel: FSWorkoutRecord) {
        let routine = WorkoutRoutineDTO(
            rmID: "",
            documentID: fsModel.id ?? "",
            name: fsModel.workoutRoutineName ?? "Unknown",
            workouts: fsModel.workouts.map { WorkoutDTO(from: $0) }
        )
        self.rmID = routine.rmID
        self.documentID = routine.documentID
        self.uuid = fsModel.uuid
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
            uuid: self.uuid,
            workouts: self.workoutRoutine?.workouts.map { $0.toFSModel() } ?? [],
            totalTime: self.totalTime,
            workoutTime: self.workoutTime,
            userId: userId,
            comment: self.comment
        )
    }
}

