//
//  WorkoutDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation

struct WorkoutDTO {
    let name: String
    let sets: [WorkoutSetDTO]
    let restTime: Int
    let comment: String?
}

extension WorkoutDTO {
    func toEntity() -> Workout {
        return Workout(name: self.name,
                       sets: self.sets.map{ $0.toEntity() },
                       restTime: self.restTime,
                       comment: self.comment)
    }
}
