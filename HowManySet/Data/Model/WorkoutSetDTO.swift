//
//  WorkoutSetDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation

struct WorkoutSetDTO {
    let weight: Double
    let unit: String
    let reps: Int
}

extension WorkoutSetDTO {
    func toEntity() -> WorkoutSet {
        return WorkoutSet(weight: self.weight,
                          unit: self.unit,
                          reps: self.reps)
    }
}
