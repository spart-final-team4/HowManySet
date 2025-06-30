//
//  WorkoutRoutineDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift


struct WorkoutRoutineDTO {
    let rmID: String
    let documentID: String
    var name: String
    var workouts: [WorkoutDTO]
}

extension WorkoutRoutineDTO {
    func toEntity() -> WorkoutRoutine {
        return WorkoutRoutine(rmID: self.rmID,
                              documentID: self.documentID,
                              name: self.name,
                              workouts: self.workouts.map { $0.toEntity() })
    }
}

extension WorkoutRoutineDTO {
    init(entity: WorkoutRoutine) {
        self.rmID = entity.rmID
        self.documentID = entity.documentID
        self.name = entity.name
        self.workouts = entity.workouts.map { WorkoutDTO(entity: $0) }
    }
}

extension WorkoutRoutineDTO {
    init(from model: RMWorkoutRoutine) {
        self.rmID = model.id
        self.documentID = ""
        self.name = model.name
        self.workouts = model.workouts.map{ WorkoutDTO(from: $0) }
    }
}

extension WorkoutRoutineDTO {
    init(from fsModel: FSWorkoutRoutine) {
        // TODO: 검토 필요
        self.rmID = ""
        self.documentID = fsModel.id ?? ""
        self.name = fsModel.name
        self.workouts = fsModel.workouts.map { WorkoutDTO(from: $0) }
    }
}

extension WorkoutRoutineDTO {
    func toFSModel(userId: String, description: String? = nil, tags: [String] = []) -> FSWorkoutRoutine {
        return FSWorkoutRoutine(
            dto: self,
            id: self.documentID,
            userId: userId,
            description: description,
            tags: tags
        )
    }
}

extension WorkoutRoutineDTO {
    static func mockData() -> WorkoutRoutineDTO {
        return WorkoutRoutineDTO(rmID: "",
                                 documentID: "",
                                 name: "",
                                 workouts: [])
    }
}


extension WorkoutRoutineDTO {
    static func toRoutineText(_ routine: Self) -> String {
        var output: String = "\(routine.rmID)&\(routine.documentID)&\(routine.name)&"

        routine.workouts.forEach { workout in
            let name = workout.name
            let rmID = workout.rmID
            let comment = workout.comment
            output += "\(rmID)%\(name)%\(comment ?? "메모 없음")%"
            
            workout.sets.forEach { exercise in
                output += "\(exercise.weight)%\(exercise.reps)%\(exercise.unit)%"
            }
            output += "$"
        }
        
        return output
    }
}
