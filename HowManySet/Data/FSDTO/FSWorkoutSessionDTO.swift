//
//  FSWorkoutSessionDTO.swift
//  HowManySet
//
//  Created by GO on 6/16/25.
//

import Foundation
import FirebaseFirestore

/// Firestore에 저장되는 운동 세션 DTO
struct FSWorkoutSessionDTO: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let recordId: String
    let startDate: Date
    let endDate: Date
}
