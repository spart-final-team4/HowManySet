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

    /// 운동 기록을 Realm에 저장합니다.
    /// - Parameters:
    ///   - uid: 사용자 식별자 (현재 사용되지 않음, 확장 가능성 대비)
    ///   - item: 저장할 운동 기록 모델 (`WorkoutRecord`)
    func saveRecord(uid: String, item: WorkoutRecord) {
        // TODO: 운동 기록 저장 구현
        let record = RMWorkoutRecord(dto: WorkoutRecordDTO(entity: item))
        RealmService.shared.create(item: record)
    }

    /// Realm에서 저장된 운동 기록을 불러옵니다.
    /// RxSwift의 Single로 비동기 데이터를 반환합니다.
    /// - Parameter uid: 사용자 식별자 (현재 사용되지 않음, 향후 사용자별 데이터 필터링에 활용 가능)
    /// - Returns: 운동 기록 배열을 성공 시 반환, 실패 시 `RealmErrorType.dataNotFound` 발생
    func fetchRecord(uid: String) -> Single<[WorkoutRecord]> {
        return Single.create { observer in
            guard let records = RealmService.shared.read(type: .workoutRecord) else {
                observer(.failure(RealmErrorType.dataNotFound))
                return Disposables.create()
            }
            let recordDTO = records.map{ ($0 as! RMWorkoutRecord).toDTO() }
            observer(.success(recordDTO.map { $0.toEntity() }))
            return Disposables.create()
        }
    }

    /// 특정 운동 기록을 삭제합니다.
    /// - Parameters:
    ///   - uid: 사용자 식별자 (현재 사용되지 않음)
    ///   - item: 삭제할 운동 기록 모델
    func deleteRecord(uid: String, item: WorkoutRecord) {
        let record = RMWorkoutRecord(dto: WorkoutRecordDTO(entity: item))
        RealmService.shared.delete(item: record)
    }

    /// 모든 운동 루틴(기록 포함)을 삭제합니다.
    /// - Parameter uid: 사용자 식별자 (현재 사용되지 않음)
    func deleteAllRecord(uid: String) {
        RealmService.shared.deleteAll(type: .workoutRecord)
    }

    /// WorkoutRecord의 메모값을 변경하는 메서드
    /// RecordDetail 페이지에서만 사용하기 때문에 comment만 변경함
    func updateRecord(uid: String, item: WorkoutRecord) {
        if let record = RealmService.shared.read(type: .workoutRecord, primaryKey: item.rmID) as? RMWorkoutRecord {
            RealmService.shared.update(item: record) { (savedRecord: RMWorkoutRecord) in
                savedRecord.comment = item.comment
            }
        }
    }
    
}
