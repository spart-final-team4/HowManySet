//
//  WorkoutRepository.swift
//  HowManySet
//
//  Created by MJ Dev on 6/23/25.
//

import Foundation

protocol WorkoutRepository {
    func updateWorkout(uid: String?, workout: Workout)
    func deleteWorkout(uid: String?, workout: Workout)
}
