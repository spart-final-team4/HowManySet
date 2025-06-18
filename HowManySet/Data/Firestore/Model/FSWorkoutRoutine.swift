//
//  FSWorkoutRoutine.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import FirebaseFirestore

struct FSWorkoutRoutine: Codable {
    @DocumentID var id: String?
    var name: String
    var workouts: [FSWorkout]
    var description: String?
    var isActive: Bool
    var userId: String
    var createdAt: Date
    var updatedAt: Date
    var tags: [String]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case workouts
        case description
        case isActive = "is_active"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case tags
    }
    
    init(
        name: String,
        workouts: [FSWorkout],
        description: String? = nil,
        userId: String,
        tags: [String] = []
    ) {
        self.id = nil
        self.name = name
        self.workouts = workouts
        self.description = description
        self.isActive = true
        self.userId = userId
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = tags
    }
}

extension FSWorkoutRoutine {
    func toDTO() -> WorkoutRoutineDTO {
        return WorkoutRoutineDTO(
            name: self.name,
            workouts: self.workouts.map { $0.toDTO() },
            description: self.description,
            isActive: self.isActive,
            userId: self.userId,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            tags: self.tags
        )
    }
}

extension FSWorkoutRoutine {
    init(dto: WorkoutRoutineDTO) {
        self.id = nil
        self.name = dto.name
        self.workouts = dto.workouts.map { FSWorkout(dto: $0) }
        self.description = dto.description
        self.isActive = dto.isActive
        self.userId = dto.userId
        self.createdAt = dto.createdAt
        self.updatedAt = Date()
        self.tags = dto.tags
    }
}
