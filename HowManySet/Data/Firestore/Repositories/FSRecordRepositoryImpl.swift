//
//  FSRecordRepositoryImpl.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import RxSwift

/// Firestore 기반 운동 기록 저장소 구현체입니다.
/// 기존 RecordRepository 프로토콜을 구현하여 일관된 인터페이스를 제공합니다.
final class FSRecordRepositoryImpl: RecordRepository {
    func updateRecord(uid: String, item: WorkoutRecord) {
        // TODO: 구현 필요
    }
    
    
    private let firestoreService: FirestoreServiceProtocol

    init(firestoreService: FirestoreServiceProtocol) {
        self.firestoreService = firestoreService
    }

    /// 운동 기록을 Firestore에 저장합니다.
    func saveRecord(uid: String, item: WorkoutRecord) {
        Task {
            do {
                let dto = WorkoutRecordDTO(entity: item)
                let fsRecord = dto.toFSModel(userId: uid)
                _ = try await firestoreService.create(item: fsRecord, type: FirestoreDataType<FSWorkoutRecord>.workoutRecord)
                print("Firestore 기록 저장 성공")
            } catch {
                print("Firestore 기록 저장 실패: \(error)")
            }
        }
    }

    /// 사용자의 운동 기록을 Firestore에서 불러옵니다.
    func fetchRecord(uid: String) -> Single<[WorkoutRecord]> {
        return Single.create { [weak self] observer in
            guard let self = self else {
                observer(.failure(FirestoreErrorType.dataNotFound))
                return Disposables.create()
            }
            
            Task {
                do {
                    let fsRecords = try await self.firestoreService.read(userId: uid, type: FirestoreDataType<FSWorkoutRecord>.workoutRecord)
                    let records = fsRecords.map { $0.toDTO().toEntity() }
                    observer(.success(records))
                } catch {
                    observer(.failure(error))
                }
            }
            
            return Disposables.create()
        }
    }

    /// 특정 운동 기록을 Firestore에서 삭제합니다.
    func deleteRecord(uid: String, item: WorkoutRecord) {
        Task {
            do {
                // TODO: WorkoutRecord에 documentId 필드 추가 필요
                // try await firestoreService.delete(id: item.documentId, type: FirestoreDataType<FSWorkoutRecord>.workoutRecord)
                print("Firestore 기록 삭제 - 구현 필요")
            } catch {
                print("Firestore 기록 삭제 실패: \(error)")
            }
        }
    }

    /// 사용자의 모든 운동 기록을 Firestore에서 삭제합니다.
    func deleteAllRecord(uid: String) {
        Task {
            do {
                try await firestoreService.deleteAll(userId: uid, type: FirestoreDataType<FSWorkoutRecord>.workoutRecord)
                print("Firestore 모든 기록 삭제 성공")
            } catch {
                print("Firestore 모든 기록 삭제 실패: \(error)")
            }
        }
    }
}
