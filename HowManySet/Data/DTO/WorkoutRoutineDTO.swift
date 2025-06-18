//
//  WorkoutRoutineDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift


struct WorkoutRoutineDTO {
    var name: String
    var workouts: [WorkoutDTO]
}

extension WorkoutRoutineDTO {
    func toEntity() -> WorkoutRoutine {
        return WorkoutRoutine(name: self.name,
                              workouts: self.workouts.map { $0.toEntity() })
    }
}

extension WorkoutRoutineDTO {
    init(entity: WorkoutRoutine) {
        self.name = entity.name
        self.workouts = entity.workouts.map { WorkoutDTO(entity: $0) }
    }
}

extension WorkoutRoutineDTO {
    init(from model: RMWorkoutRoutine) {
        self.name = model.name
        self.workouts = model.workouts.map{ WorkoutDTO(from: $0) }
    }
}
