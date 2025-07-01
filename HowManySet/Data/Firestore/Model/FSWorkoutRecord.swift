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
    var workoutRoutineId: String?
    var workoutRoutineName: String?
    var uuid: String
    var workouts: [FSWorkout]  // 개별 운동들이 아닌 전체 루틴
    var totalTime: Int
    var workoutTime: Int
    var completedAt: Date
    var userId: String
    var comment: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case workoutRoutineId = "workout_routine_id"
        case workoutRoutineName = "workout_routine_name"
        case uuid
        case workouts
        case totalTime = "total_time"
        case workoutTime = "workout_time"
        case completedAt = "completed_at"
        case userId = "user_id"
        case comment
    }
    
    init(
        workoutRoutineId: String?,
        workoutRoutineName: String?,
        uuid: String,
        workouts: [FSWorkout],
        totalTime: Int,
        workoutTime: Int,
        userId: String,
        comment: String? = nil
    ) {
        self.id = nil
        self.workoutRoutineId = workoutRoutineId
        self.workoutRoutineName = workoutRoutineName
        self.uuid = uuid
        self.workouts = workouts
        self.totalTime = totalTime
        self.workoutTime = workoutTime
        self.completedAt = Date()
        self.userId = userId
        self.comment = comment
    }
}

extension FSWorkoutRecord {
    func toDTO() -> WorkoutRecordDTO {
        let routine = WorkoutRoutineDTO(
            rmID: "",
            documentID: self.id ?? "",
            name: self.workoutRoutineName ?? "Unknown",
            workouts: self.workouts.map { $0.toDTO() }
        )
        
        return WorkoutRecordDTO(
            rmID: "",
            documentID: self.id ?? "",
            uuid: self.uuid,
            workoutRoutine: routine,
            totalTime: self.totalTime,
            workoutTime: self.workoutTime,
            comment: self.comment,
            date: self.completedAt
        )
    }
}

extension FSWorkoutRecord {
    init(dto: WorkoutRecordDTO, userId: String) {
        self.id = nil
        self.uuid = dto.uuid
        self.workoutRoutineId = nil // DTO에는 ID 정보가 없음
        self.workoutRoutineName = dto.workoutRoutine?.name
        self.workouts = dto.workoutRoutine?.workouts.map { $0.toFSModel() } ?? []
        self.totalTime = dto.totalTime
        self.workoutTime = dto.workoutTime
        self.completedAt = dto.date
        self.userId = userId
        self.comment = dto.comment
    }
}
