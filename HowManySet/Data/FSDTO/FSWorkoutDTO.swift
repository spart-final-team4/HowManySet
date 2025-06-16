//
//  FSWorkoutDTO.swift
//  HowManySet
//
//  Created by GO on 6/16/25.
//

import Foundation
import FirebaseFirestore

/// Firestore에 저장되는 운동 DTO
struct FSWorkoutDTO: Codable {
    let name: String
    let sets: [FSWorkoutSetDTO]
    let comment: String?
}
