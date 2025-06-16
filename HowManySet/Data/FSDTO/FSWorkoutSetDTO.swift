//
//  FSWorkoutSetDTO.swift
//  HowManySet
//
//  Created by GO on 6/16/25.
//

import Foundation
import FirebaseFirestore

/// Firestore에 저장되는 운동 세트 DTO
struct FSWorkoutSetDTO: Codable {
    let weight: Double
    let unit: String
    let reps: Int
}
