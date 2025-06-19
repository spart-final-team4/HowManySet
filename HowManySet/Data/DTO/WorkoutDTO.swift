//
//  WorkoutDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

struct WorkoutDTO {
    var name: String
    var comment: String?
    var sets: [WorkoutSetDTO]
}

extension WorkoutDTO {
    func toEntity() -> Workout {
        return Workout(
            name: self.name,
            sets: self.sets.map { $0.toEntity() },
            comment: self.comment)
    }
}

extension WorkoutDTO {
    init(entity: Workout) {
        self.name = entity.name
        self.comment = entity.comment
        self.sets = entity.sets.map { WorkoutSetDTO(entity: $0) }
    }
}

extension WorkoutDTO {
    init(from model: RMWorkout) {
        self.name = model.name
        self.comment = model.comment
        self.sets = model.sets.map { WorkoutSetDTO(from: $0) }
    }
}

extension WorkoutDTO {
    init(from fsModel: FSWorkout) {
        self.name = fsModel.name
        self.comment = fsModel.comment
        self.sets = fsModel.sets.map { WorkoutSetDTO(from: $0) }
    }
}

extension WorkoutDTO {
    func toFSModel() -> FSWorkout {
        return FSWorkout(
            name: self.name,
            sets: self.sets.map { $0.toFSModel() },
            comment: self.comment
        )
    }
}
