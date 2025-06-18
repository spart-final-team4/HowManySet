//
//  WorkoutSetDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

struct WorkoutSetDTO {
    var weight: Double
    var unit: String
    var reps: Int
}

extension WorkoutSetDTO {
    func toEntity() -> WorkoutSet {
        return WorkoutSet(weight: self.weight,
                          unit: self.unit,
                          reps: self.reps)
    }
}
extension WorkoutSetDTO {
    init(entity: WorkoutSet) {
        self.weight = entity.weight
        self.unit = entity.unit
        self.reps = entity.reps
    }
}

extension WorkoutSetDTO {
    init(from model: RMWorkoutSet) {
        self.weight = model.weight
        self.unit = model.unit
        self.reps = model.reps
    }
}
