//
//  RoutineRepositoryImpl.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift

/// `RoutineRepository` 프로토콜을 구현한 운동 루틴 저장소 클래스입니다.
///
/// 실제 데이터 소스(예: 데이터베이스, 네트워크 등)와 연동하여 운동 루틴을 조회, 저장, 수정, 삭제하는 기능을 제공합니다.
final class RoutineRepositoryImpl: RoutineRepository {
    
    private let firestoreService: FirestoreServiceProtocol
    
    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 저장합니다.
    ///
    /// - Parameters:
    ///   - item: 저장할 `WorkoutRoutine` 객체
    func saveRoutine(uid: String?, item: WorkoutRoutine) {
        if let uid {
            createRoutineToFirebase(uid: uid, to: item)
        } else {
            createRoutineToRealm(to: item)
        }
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴 리스트를 비동기적으로 조회합니다.
    ///
    /// - Returns: `Single`로 감싸진 `WorkoutRoutine` 배열, 조회 성공 시 배열을 방출하고 실패 시 에러를 방출합니다.
    func fetchRoutine(uid: String?) -> Single<[WorkoutRoutine]> {
        if let uid {
            return fetchRoutineFromFirebase(uid: uid)
        } else {
            return fetchRoutineFromRealm()
        }
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 수정합니다.
    ///
    /// - Parameters:
    ///   - item: 수정할 `WorkoutRoutine` 객체 덮어쓰기
    func updateRoutine(uid: String?, item: WorkoutRoutine) {
        if let uid {
            updateRoutineWithFirebase(uid: uid, item: item)
        } else {
            updateRoutineWithRelam(item: item)
        }
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 삭제합니다.
    ///
    /// - Parameters:
    ///   - item: 삭제할 `WorkoutRoutine` 객체
    func deleteRoutine(uid: String?, item: WorkoutRoutine) {
        if let uid {
            deleteRoutineFromFirebase(uid: uid, item: item)
        } else {
            deleteRoutineFromRealm(item: item)
        }
    }
}


private extension RoutineRepositoryImpl {
    // MARK: Routine Create
    func createRoutineToFirebase(uid: String, to item: WorkoutRoutine) {
        Task {
            do {
                let dto = WorkoutRoutineDTO(entity: item)
                let fsRoutine = dto.toFSModel(userId: uid)
                _ = try await firestoreService.create(item: fsRoutine, type: FirestoreDataType<FSWorkoutRoutine>.workoutRoutine)
                print("Firestore 루틴 저장 성공")
            } catch {
                print("Firestore 루틴 저장 실패: \(error)")
            }
        }
    }
    
    func createRoutineToRealm(to item: WorkoutRoutine) {
        let routine = RMWorkoutRoutine(dto: WorkoutRoutineDTO(entity: item))
        RealmService.shared.create(item: routine)
    }
    
    // MARK: Routine Read
    func fetchRoutineFromFirebase(uid: String) -> Single<[WorkoutRoutine]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(FirestoreErrorType.dataNotFound))
                return Disposables.create()
            }
            
            Task {
                do {
                    let fsRoutines = try await self.firestoreService.read(userId: uid, type: FirestoreDataType<FSWorkoutRoutine>.workoutRoutine)
                    let routines = fsRoutines.map { $0.toDTO().toEntity() }
                    observer(.success(routines))
                } catch {
                    observer(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchRoutineFromRealm() -> Single<[WorkoutRoutine]> {
        return Single.create { observer in
            guard let routines = RealmService.shared.read(type: .workoutRoutine) else {
                observer(.failure(RealmErrorType.dataNotFound))
                return Disposables.create()
            }
            
            let routineDTO: [WorkoutRoutineDTO] = routines.map{ ($0 as! RMWorkoutRoutine).toDTO()}
            // 예시: 빈 배열 반환
            observer(.success(routineDTO.map{$0.toEntity()}))
            
            return Disposables.create()
        }
    }
    
    // MARK: Routine Update
    func updateRoutineWithFirebase(uid: String, item: WorkoutRoutine) {
        Task {
            do {
                let dto = WorkoutRoutineDTO(entity: item)
                let fsRoutine = dto.toFSModel(userId: uid)
                try await firestoreService.update(
                    id: item.documentID,
                    item: fsRoutine,
                    type: FirestoreDataType<FSWorkoutRoutine>.workoutRoutine
                )
                print("Firestore 루틴 업데이트 성공")
            } catch {
                print("Firestore 루틴 업데이트 실패: \(error)")
            }
        }
    }
    
    func updateRoutineWithRelam(item: WorkoutRoutine) {
        if let routine = RealmService.shared.read(type: .workoutRoutine,
                                                  primaryKey: item.rmID)
            as? RMWorkoutRoutine {
            let newRMWorkout = item.workouts.map{ RMWorkout(dto: WorkoutDTO(entity: $0))}
            RealmService.shared.updateRoutine(item: routine, workouts: newRMWorkout) { routine in
                routine.name = item.name
                routine.workoutArray = newRMWorkout
            }
        }
    }
    
    // MARK: Routine Delete
    func deleteRoutineFromFirebase(uid: String, item: WorkoutRoutine) {
        Task {
            do {
                try await firestoreService.delete(
                    id: item.documentID,
                    type: FirestoreDataType<FSWorkoutRoutine>.workoutRoutine
                )
                print("Firestore 루틴 삭제 성공")
            } catch {
                print("Firestore 루틴 삭제 실패: \(error)")
            }
        }
    }
    
    func deleteRoutineFromRealm(item: WorkoutRoutine) {
        let routine = RMWorkoutRoutine(dto: WorkoutRoutineDTO(entity: item))
        RealmService.shared.delete(item: routine)
    }
}
