//
//  WorkoutRoutineDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation

struct WorkoutRoutineDTO {
    let name: String
    let workouts: [WorkoutDTO]
}

extension WorkoutRoutineDTO {
    func toEntity() -> WorkoutRoutine {
        return WorkoutRoutine(name: self.name,
                              workouts: self.workouts.map{ $0.toEntity() })
    }
}
