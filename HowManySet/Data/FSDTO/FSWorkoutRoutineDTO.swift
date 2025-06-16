//
//  FSWorkoutRoutineDTO.swift
//  HowManySet
//
//  Created by GO on 6/16/25.
//

import Foundation
import FirebaseFirestore

/// Firestore에 저장되는 운동 루틴 DTO
struct FSWorkoutRoutineDTO: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let name: String
    let workouts: [FSWorkoutDTO]
}
