//
//  FSWorkoutRecordDTO.swift
//  HowManySet
//
//  Created by GO on 6/16/25.
//

import Foundation
import FirebaseFirestore

/// Firestore에 저장되는 운동 기록 DTO
struct FSWorkoutRecordDTO: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let routineId: String
    let totalTime: Int
    let workoutTime: Int
    let comment: String?
    let date: Date
}
