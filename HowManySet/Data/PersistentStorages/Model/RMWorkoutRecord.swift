//
//  WorkoutRecord.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift


final class RMWorkoutRecord: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var workoutRoutine: RMWorkoutRoutine?
    @Persisted var totalTime: Int
    @Persisted var workoutTime: Int
    @Persisted var comment: String?
    @Persisted var date: Date

    convenience init(
        workoutRoutine: RMWorkoutRoutine,
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
    
    override static func primaryKey() -> String? {
        return "rmID"
    }
}

extension RMWorkoutRecord {
    func toDTO() -> WorkoutRecordDTO {
        return WorkoutRecordDTO(
            rmID: self.id,
            workoutRoutine: self.workoutRoutine?.toDTO()
            ?? WorkoutRoutineDTO.mockData(),
            totalTime: self.totalTime,
            workoutTime: self.workoutTime,
            comment: self.comment,
            date: self.date
        )
    }
}

extension RMWorkoutRecord {
    convenience init(dto: WorkoutRecordDTO) {
        self.init()
        self.id = dto.rmID
        self.workoutRoutine = RMWorkoutRoutine(dto: dto.workoutRoutine ?? WorkoutRoutineDTO.mockData())
        self.totalTime = dto.totalTime
        self.workoutTime = dto.workoutTime
        self.comment = dto.comment
        self.date = dto.date
    }
}
