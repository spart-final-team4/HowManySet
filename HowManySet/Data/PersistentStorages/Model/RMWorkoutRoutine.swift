//
//  WorkoutRoutineDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

final class RMWorkoutRoutine: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var workouts = List<RMWorkout>()

    var workoutArray: [RMWorkout] {
        get {
            return workouts.map { $0 }
        }
        set {
            workouts.removeAll()
            workouts.append(objectsIn: newValue)
        }
    }
    convenience init(
        name: String,
        workouts: [RMWorkout]
    ) {
        self.init()
        self.name = name
        self.workoutArray = workouts
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RMWorkoutRoutine {
    func toDTO() -> WorkoutRoutineDTO {
        return WorkoutRoutineDTO(id: self.id,
                                 name: self.name,
                                 workouts: self.workouts.map { $0.toDTO() })
    }
}

extension RMWorkoutRoutine {
    convenience init(dto: WorkoutRoutineDTO) {
        self.init()
        self.id = dto.id
        self.name = dto.name
        self.workoutArray = dto.workouts.map { RMWorkout(dto: $0) }
    }
}
