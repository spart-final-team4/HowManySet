//
//  WorkoutRoutineDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift


struct WorkoutRoutineDTO {
    let id: String
    var name: String
    var workouts: [WorkoutDTO]
}

extension WorkoutRoutineDTO {
    func toEntity() -> WorkoutRoutine {
        return WorkoutRoutine(id: self.id,
                              name: self.name,
                              workouts: self.workouts.map { $0.toEntity() })
    }
}

extension WorkoutRoutineDTO {
    init(entity: WorkoutRoutine) {
        self.id = entity.id
        self.name = entity.name
        self.workouts = entity.workouts.map { WorkoutDTO(entity: $0) }
    }
}

extension WorkoutRoutineDTO {
    init(from model: RMWorkoutRoutine) {
        self.id = model.id
        self.name = model.name
        self.workouts = model.workouts.map{ WorkoutDTO(from: $0) }
    }
}

extension WorkoutRoutineDTO {
    init(from fsModel: FSWorkoutRoutine) {
        // TODO: 검토 필요
        self.id = fsModel.id ?? ""
        self.name = fsModel.name
        self.workouts = fsModel.workouts.map { WorkoutDTO(from: $0) }
    }
}

extension WorkoutRoutineDTO {
    func toFSModel(userId: String, description: String? = nil, tags: [String] = []) -> FSWorkoutRoutine {
        return FSWorkoutRoutine(
            dto: self,
            userId: userId,
            description: description,
            tags: tags
        )
    }
}

