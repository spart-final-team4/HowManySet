//
//  FSWorkoutRecord.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import FirebaseFirestore

struct FSWorkoutRecord: Codable {
    @DocumentID var id: String?
    var workoutId: String
    var workoutName: String
    var sets: [FSWorkoutSet]
    var totalDuration: TimeInterval
    var completedAt: Date
    var userId: String
    var comment: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case workoutId = "workout_id"
        case workoutName = "workout_name"
        case sets
        case totalDuration = "total_duration"
        case completedAt = "completed_at"
        case userId = "user_id"
        case comment
    }
    
    init(
        workoutId: String,
        workoutName: String,
        sets: [FSWorkoutSet],
        totalDuration: TimeInterval,
        userId: String,
        comment: String? = nil
    ) {
        self.id = nil
        self.workoutId = workoutId
        self.workoutName = workoutName
        self.sets = sets
        self.totalDuration = totalDuration
        self.completedAt = Date()
        self.userId = userId
        self.comment = comment
    }
}

extension FSWorkoutRecord {
    func toDTO() -> WorkoutRecordDTO {
        return WorkoutRecordDTO(
            workoutId: self.workoutId,
            workoutName: self.workoutName,
            sets: self.sets.map { $0.toDTO() },
            totalDuration: self.totalDuration,
            completedAt: self.completedAt,
            userId: self.userId,
            comment: self.comment
        )
    }
}

extension FSWorkoutRecord {
    init(dto: WorkoutRecordDTO) {
        self.id = nil
        self.workoutId = dto.workoutId
        self.workoutName = dto.workoutName
        self.sets = dto.sets.map { FSWorkoutSet(dto: $0) }
        self.totalDuration = dto.totalDuration
        self.completedAt = dto.completedAt
        self.userId = dto.userId
        self.comment = dto.comment
    }
}
