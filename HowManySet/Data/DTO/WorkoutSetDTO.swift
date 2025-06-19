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

extension WorkoutSetDTO {
    init(from fsModel: FSWorkoutSet) {
        self.weight = fsModel.weight
        self.unit = fsModel.unit
        self.reps = fsModel.reps
    }
}

extension WorkoutSetDTO {
    func toFSModel(restTime: Int = 60, isCompleted: Bool = false, order: Int = 0) -> FSWorkoutSet {
        return FSWorkoutSet(
            dto: self,
            restTime: restTime,
            isCompleted: isCompleted,
            order: order
        )
    }
}

