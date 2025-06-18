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
    var reps: Int
    var restTime: Int
    var isCompleted: Bool
    var order: Int
    
    private enum CodingKeys: String, CodingKey {
        case weight
        case reps
        case restTime = "rest_time"
        case isCompleted = "is_completed"
        case order
    }
    
    init(
        weight: Double,
        reps: Int,
        restTime: Int,
        isCompleted: Bool = false,
        order: Int
    ) {
        self.weight = weight
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
            reps: self.reps,
            restTime: self.restTime,
            isCompleted: self.isCompleted,
            order: self.order
        )
    }
}

extension FSWorkoutSet {
    init(dto: WorkoutSetDTO) {
        self.weight = dto.weight
        self.reps = dto.reps
        self.restTime = dto.restTime
        self.isCompleted = dto.isCompleted
        self.order = dto.order
    }
}
