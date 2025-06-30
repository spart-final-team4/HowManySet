//
//  FSWorkout.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import FirebaseFirestore

struct FSWorkout: Codable {
    @DocumentID var id: String?
    var rmID: String?
    var name: String
    var comment: String?
    var sets: [FSWorkoutSet]
    var createdAt: Date
    var updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case comment
        case sets
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(
        // TODO: 검토 필요
        rmID: String?,
        name: String,
        sets: [FSWorkoutSet],
        comment: String? = nil
    ) {
        self.id = nil
        // TODO: 검토 필요
        self.rmID = rmID
        self.name = name
        self.comment = comment
        self.sets = sets
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

extension FSWorkout {
    func toDTO() -> WorkoutDTO {
        return WorkoutDTO(
            // TODO: 검토 필요
            rmID: self.rmID ?? "",
            name: self.name,
            comment: self.comment,
            sets: self.sets.map { $0.toDTO() }
        )
    }
}

extension FSWorkout {
    init(dto: WorkoutDTO) {
        self.id = nil
        self.name = dto.name
        self.comment = dto.comment
        self.sets = dto.sets.map { FSWorkoutSet(dto: $0) }
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
