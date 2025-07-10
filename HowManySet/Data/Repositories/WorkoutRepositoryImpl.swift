//
//  WorkoutRepositoryImpl.swift
//  HowManySet
//
//  Created by MJ Dev on 6/23/25.
//

import Foundation

final class WorkoutRepositoryImpl: WorkoutRepository {
    
    private let firestoreService: FirestoreServiceProtocol
    private let realmService: RealmServiceProtocol
    
    init(
        firestoreService: FirestoreServiceProtocol,
        realmService: RealmServiceProtocol
    ) {
        self.firestoreService = firestoreService
        self.realmService = realmService
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
                    id: workout.documentID ?? "",
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
        do {
            if let newWorkout = try realmService.read(type: .workout, primaryKey: workout.id) as? RMWorkout {
                try realmService.update(item: newWorkout) { (savedWorkout: RMWorkout) in
                    savedWorkout.name = workout.name
                    savedWorkout.comment = workout.comment
                    savedWorkout.setArray = workout.sets.map{ RMWorkoutSet(dto: WorkoutSetDTO(entity: $0)) }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Workout Delete
    func deleteWorkoutFirebase(uid: String, workout: Workout) {
        Task {
            do {
                let fsWorkout = FSWorkout(dto: WorkoutDTO(entity: workout))
                try await firestoreService.deleteWorkout(id: workout.documentID ?? "",
                                                         item: fsWorkout)
                print("Firestore 운동 삭제 성공")
            } catch {
                print("Firestore 운동 삭제 실패: \(error)")
            }
        }
    }
    
    func deleteWorkoutRealm(workout: Workout) {
        do {
            if let workout = try realmService.read(type: .workout, primaryKey: workout.id) as? RMWorkout {
                try realmService.delete(item: workout)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
