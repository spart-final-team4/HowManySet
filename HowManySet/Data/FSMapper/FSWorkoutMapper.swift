//
//  FSWorkoutMapper.swift
//  HowManySet
//
//  Created by GO on 6/16/25.
//

import Foundation

// MARK: - WorkoutSet Mapper
extension FSWorkoutSetDTO {
    func toDomain() -> WorkoutSet {
        return WorkoutSet(weight: self.weight,
                          unit: self.unit,
                          reps: self.reps)
    }
}

extension WorkoutSet {
    func toFSDTO() -> FSWorkoutSetDTO {
        return FSWorkoutSetDTO(weight: self.weight,
                               unit: self.unit,
                               reps: self.reps)
    }
}
