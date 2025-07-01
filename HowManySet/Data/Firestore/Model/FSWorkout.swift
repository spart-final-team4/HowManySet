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
    var uuid: String
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
        case uuid
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(
        uuid: String,
        name: String,
        sets: [FSWorkoutSet],
        comment: String? = nil
    ) {
        self.uuid = uuid
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
            id: self.uuid,
            documentID: self.id,
            name: self.name,
            comment: self.comment,
            sets: self.sets.map { $0.toDTO() }
        )
    }
}

extension FSWorkout {
    init(dto: WorkoutDTO) {
        self.uuid = dto.id
        self.name = dto.name
        self.comment = dto.comment
        self.sets = dto.sets.map { FSWorkoutSet(dto: $0) }
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
