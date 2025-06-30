//
//  WorkoutRepositoryImpl.swift
//  HowManySet
//
//  Created by MJ Dev on 6/23/25.
//

import Foundation

final class WorkoutRepositoryImpl: WorkoutRepository {
    
    private let firestoreService: FirestoreServiceProtocol
    
    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }
    
    func deleteWorkout(uid: String?, workout: Workout) {
        if let uid {
            deleteWorkoutFirebase(uid: uid, workout: workout)
        } else {
            deleteWorkoutRealm(workout: workout)
        }
    }
    
    func updateWorkout(uid: String?, workout: Workout) {
        if let uid {
            updateWorkoutFirebase(uid: uid, workout: workout)
        } else {
            updateWorkoutRealm(workout: workout)
        }
    }
}

private extension WorkoutRepositoryImpl {
    // MARK: - Workout Update
    func updateWorkoutFirebase(uid: String, workout: Workout) {
        Task {
            do {
                let dto = WorkoutDTO(entity: workout)
                let fsWorkout = dto.toFSModel()
                try await firestoreService.update(
                    id: workout.id,
                    item: fsWorkout,
                    type: FirestoreDataType<FSWorkout>.workout
                )
                print("Firestore 운동 업데이트 성공")
            } catch {
                print("Firestore 운동 업데이트 실패: \(error)")
            }
        }
    }
    
    func updateWorkoutRealm(workout: Workout) {
        if let newWorkout = RealmService.shared.read(type: .workout, primaryKey: workout.id) as? RMWorkout {
            RealmService.shared.update(item: newWorkout) { (savedWorkout: RMWorkout) in
                savedWorkout.name = workout.name
                savedWorkout.comment = workout.comment
                savedWorkout.setArray = workout.sets.map{ RMWorkoutSet(dto: WorkoutSetDTO(entity: $0)) }
            }
        }
    }
    
    // MARK: - Workout Delete
    func deleteWorkoutFirebase(uid: String, workout: Workout) {
        // TODO: 구현 필요
        print("deleteWorkoutFirebase 구현안되있음")
    }
    func deleteWorkoutRealm(workout: Workout) {
        if let workout = RealmService.shared.read(type: .workout, primaryKey: workout.id) as? RMWorkout {
            RealmService.shared.delete(item: workout)
        }
    }
    
}
