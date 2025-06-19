//
//  FSWorkoutSet.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import FirebaseFirestore

struct FSWorkoutSet: Codable {
    var weight: Double
    var unit: String
    var reps: Int
    var restTime: Int
    var isCompleted: Bool
    var order: Int
    
    private enum CodingKeys: String, CodingKey {
        case weight
        case unit
        case reps
        case restTime = "rest_time"
        case isCompleted = "is_completed"
        case order
    }
    
    init(
        weight: Double,
        unit: String = "kg",
        reps: Int,
        restTime: Int = 60,
        isCompleted: Bool = false,
        order: Int = 0
    ) {
        self.weight = weight
        self.unit = unit
        self.reps = reps
        self.restTime = restTime
        self.isCompleted = isCompleted
        self.order = order
    }
}

extension FSWorkoutSet {
    func toDTO() -> WorkoutSetDTO {
        return WorkoutSetDTO(
            weight: self.weight,
            unit: self.unit,
            reps: self.reps
        )
    }
}

extension FSWorkoutSet {
    init(dto: WorkoutSetDTO, restTime: Int = 60, isCompleted: Bool = false, order: Int = 0) {
        self.weight = dto.weight
        self.unit = dto.unit
        self.reps = dto.reps
        self.restTime = restTime
        self.isCompleted = isCompleted
        self.order = order
    }
}
