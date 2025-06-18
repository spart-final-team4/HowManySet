//
//  RMWorkout.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

final class RMWorkout: Object {
    @Persisted var name: String
    @Persisted var comment: String?
    @Persisted var sets = List<RMWorkoutSet>()

    var setArray: [RMWorkoutSet] {
        get {
            return sets.map { $0 }
        }
        set {
            sets.removeAll()
            sets.append(objectsIn: newValue)
        }
    }
    
    convenience init(
        name: String,
        sets: [RMWorkoutSet],
        restTime: Int,
        comment: String? = nil
    ) {
        self.init()
        self.name = name
        self.comment = comment
        self.setArray = sets
    }
}

extension RMWorkout {
    func toDTO() -> WorkoutDTO {
        return WorkoutDTO(name: self.name,
                          comment: self.comment,
                          sets: self.sets.map { $0.toDTO() })
    }
}

extension RMWorkout {
    convenience init(dto: WorkoutDTO) {
        self.init()
        self.name = dto.name
        self.comment = dto.comment
        self.setArray = dto.sets.map{ RMWorkoutSet(dto: $0) }
    }
}
