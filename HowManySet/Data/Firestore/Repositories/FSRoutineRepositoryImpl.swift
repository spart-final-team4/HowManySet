//
//  FSRoutineRepositoryImpl.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import RxSwift

/// Firestore 기반 운동 루틴 저장소 구현체입니다.
/// 기존 RoutineRepository 프로토콜을 구현하여 일관된 인터페이스를 제공합니다.
final class FSRoutineRepositoryImpl: RoutineRepository {
    
    private let firestoreService: FirestoreServiceProtocol
    
    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }
    
    /// 사용자의 운동 루틴을 Firestore에서 불러옵니다.
    func fetchRoutine(uid: String) -> Single<[WorkoutRoutine]> {
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
    
    /// 운동 루틴을 Firestore에서 삭제합니다.
    func deleteRoutine(uid: String, item: WorkoutRoutine) {
        Task {
            do {
                // TODO: WorkoutRoutine에 documentId 필드 추가 필요
                // try await firestoreService.delete(id: item.documentId, type: .workoutRoutine)
                print("Firestore 루틴 삭제 - 구현 필요")
            } catch {
                print("Firestore 루틴 삭제 실패: \(error)")
            }
        }
    }
    
    /// 운동 루틴을 Firestore에 저장합니다.
    func saveRoutine(uid: String, item: WorkoutRoutine) {
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
    
    /// 운동 루틴을 Firestore에서 수정합니다.
    func updateRoutine(uid: String, item: WorkoutRoutine) {
        Task {
            do {
                // TODO: WorkoutRoutine에 documentId 필드 추가 필요
                let dto = WorkoutRoutineDTO(entity: item)
                let fsRoutine = dto.toFSModel(userId: uid)
                // try await firestoreService.update(id: item.documentId, item: fsRoutine, type: .workoutRoutine)
                print("Firestore 루틴 업데이트 - 구현 필요")
            } catch {
                print("Firestore 루틴 업데이트 실패: \(error)")
            }
        }
    }
}
