//
//  RecordRepository.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift
/// RecordRepository
/// uid nil 여부에 따라 Realm, Firebase 저장위치가 상이
protocol RecordRepository {
    func saveRecord(uid: String?, item: WorkoutRecord)
    func fetchRecord(uid: String?) -> Single<[WorkoutRecord]>
    func updateRecord(uid: String?, item: WorkoutRecord)
    func deleteRecord(uid: String?, item: WorkoutRecord)
    func deleteAllRecord(uid: String?)

    /// Firestore 저장 완료를 보장하는 async 저장 메서드 (migration 전용)
    func saveRecordAsync(uid: String, item: WorkoutRecord) async throws
}
