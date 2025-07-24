//
//  RecordRepositoryImpl.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift

/// 운동 기록(WorkoutRecord)에 대한 데이터 처리 로직을 담당하는 저장소 구현체입니다.
/// RealmService를 통해 로컬 Realm 데이터베이스와 상호작용합니다.
final class RecordRepositoryImpl: RecordRepository {
    
    private let firestoreService: FirestoreServiceProtocol
    private let realmService: RealmServiceProtocol
    
    init(
        firestoreService: FirestoreServiceProtocol,
        realmService: RealmServiceProtocol
    ) {
        self.firestoreService = firestoreService
        self.realmService = realmService
    }
    
    func saveRecord(uid: String?, item: WorkoutRecord) {
        if let uid {
            createRecordToFirebase(uid: uid, item: item)
        } else {
            createRecordToRealm(item: item)
        }
    }
    
    func fetchRecord(uid: String?) -> Single<[WorkoutRecord]> {
        if let uid {
            return readRecordFromFirebase(uid: uid)
        } else {
            return readRecordFromRealm()
        }
    }
    
    func updateRecord(uid: String?, item: WorkoutRecord) {
        if let uid {
            updateRecordToFirebase(uid: uid, item: item)
        } else {
            updateRecordToRealm(item: item)
        }
    }
    
    func deleteRecord(uid: String?, item: WorkoutRecord) {
        if let uid {
            deleteRecordToFirebase(uid: uid, item: item)
        } else {
            deleteRecordToRealm(item: item)
        }
    }
    
    func deleteAllRecord(uid: String?) {
        if let uid {
            deleteAllRecordFirebase(uid: uid)
        } else {
            deleteAllRecordRealm()
        }
    }
}

private extension RecordRepositoryImpl {
    
    // MARK: - Record Create
    func createRecordToFirebase(uid: String, item: WorkoutRecord) {
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
    
    func createRecordToRealm(item: WorkoutRecord) {
        let record = RMWorkoutRecord(dto: WorkoutRecordDTO(entity: item))
        do {
            try realmService.create(item: record)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Record Read
    func readRecordFromFirebase(uid: String) -> Single<[WorkoutRecord]> {
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
    
    func readRecordFromRealm() -> Single<[WorkoutRecord]> {
        return Single.create {[unowned self] observer in
            do {
                let records = try self.realmService.read(type: .workoutRecord)
                let recordDTO = records.map{ ($0 as! RMWorkoutRecord).toDTO() }
                observer(.success(recordDTO.map { $0.toEntity() }))
            } catch {
                observer(.failure(error))
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Record Update
    func updateRecordToFirebase(uid: String, item: WorkoutRecord) {
        Task {
            do {
                let dto = WorkoutRecordDTO(entity: item)
                let fsRecord = dto.toFSModel(userId: uid)
                try await firestoreService.updateRecord(id: item.documentID,
                                                        item: fsRecord)
                print("Firestore 기록 업데이트 성공")
            } catch {
                print("Firestore 기록 업데이트 실패: \(error)")
            }
        }
    }
    
    func updateRecordToRealm(item: WorkoutRecord) {
        do {
            if let record = try realmService.read(type: .workoutRecord, primaryKey: item.rmID) as? RMWorkoutRecord {
                try realmService.update(item: record) { (savedRecord: RMWorkoutRecord) in
                    savedRecord.comment = item.comment
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    // MARK: - Record Delete
    func deleteRecordToFirebase(uid: String, item: WorkoutRecord) {
        Task {
            do {
                try await firestoreService.delete(
                    id: item.documentID,
                    type: FirestoreDataType<FSWorkoutRecord>.workoutRecord
                )
                print("Firestore 기록 삭제 성공")
            } catch {
                print("Firestore 기록 삭제 실패: \(error)")
            }
        }
    }
    
    func deleteRecordToRealm(item: WorkoutRecord) {
        let record = RMWorkoutRecord(dto: WorkoutRecordDTO(entity: item))
        do {
            try realmService.delete(item: record)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Record Delete All
    func deleteAllRecordFirebase(uid: String) {
        Task {
            do {
                try await firestoreService.deleteAll(userId: uid, type: FirestoreDataType<FSWorkoutRecord>.workoutRecord)
                print("Firestore 모든 기록 삭제 성공")
            } catch {
                print("Firestore 모든 기록 삭제 실패: \(error)")
            }
        }
    }
    
    func deleteAllRecordRealm() {
        do {
            try realmService.deleteAll(type: .workoutRecord)
        } catch {
            print(error.localizedDescription)
        }
    }
}
