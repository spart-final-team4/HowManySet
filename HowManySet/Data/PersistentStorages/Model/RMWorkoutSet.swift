//
//  RMWorkoutSet.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

final class RMWorkoutSet: Object {
    @Persisted var weight: Double
    @Persisted var unit: String
    @Persisted var reps: Int

    convenience init(
        weight: Double,
        unit: String,
        reps: Int
    ) {
        self.init()
        self.weight = weight
        self.unit = unit
        self.reps = reps
    }
}

extension RMWorkoutSet {
    func toDTO() -> WorkoutSetDTO {
        return WorkoutSetDTO(
                             weight: self.weight,
                          unit: self.unit,
                          reps: self.reps)
    }
}

extension RMWorkoutSet {
    convenience init(dto: WorkoutSetDTO) {
        self.init()
        self.weight = dto.weight
        self.unit = dto.unit
        self.reps = dto.reps
    }
}
