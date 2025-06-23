//
//  WorkoutRepositoryImpl.swift
//  HowManySet
//
//  Created by MJ Dev on 6/23/25.
//

import Foundation

final class WorkoutRepositoryImpl: WorkoutRepository {
    
    func deleteWorkout(uid: String, workout: Workout) {
        if let workout = RealmService.shared.read(type: .workout, primaryKey: workout.id) as? RMWorkout {
            RealmService.shared.delete(item: workout)
        }
    }
    
    func updateWorkout(uid: String, workout: Workout) {
        if let workout = RealmService.shared.read(type: .workout, primaryKey: workout.id) as? RMWorkout {
            RealmService.shared.update(item: workout) { (savedWorkout: RMWorkout) in
                savedWorkout.name = workout.name
                savedWorkout.comment = workout.comment
                savedWorkout.sets = workout.sets
            }
        }
    }
}
