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
        if let newWorkout = RealmService.shared.read(type: .workout, primaryKey: workout.id) as? RMWorkout {
            RealmService.shared.update(item: newWorkout) { (savedWorkout: RMWorkout) in
                savedWorkout.name = workout.name
                savedWorkout.comment = workout.comment
                savedWorkout.setArray = workout.sets.map{ RMWorkoutSet(dto: WorkoutSetDTO(entity: $0)) }
            }
        }
    }
}
