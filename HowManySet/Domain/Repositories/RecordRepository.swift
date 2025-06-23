//
//  RecordRepository.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift

/// 운동 기록(WorkoutRecord)에 대한 저장소 인터페이스입니다.
/// 로컬 저장소 또는 원격 저장소 등 다양한 저장 방식에 유연하게 대응할 수 있도록 설계되었습니다.
protocol RecordRepository {
    
    /// 운동 기록을 저장합니다.
    /// - Parameters:
    ///   - uid: 사용자 식별자
    ///   - item: 저장할 운동 기록 엔티티
    func saveRecord(uid: String, item: WorkoutRecord)
    
    /// 운동 기록을 불러옵니다.
    /// - Parameter uid: 사용자 식별자
    /// - Returns: 운동 기록 목록을 RxSwift `Single` 형태로 반환합니다.
    ///            성공 시 `[WorkoutRecord]`를, 실패 시 에러를 반환합니다.
    func fetchRecord(uid: String) -> Single<[WorkoutRecord]>
    
    /// 특정 운동 기록을 삭제합니다.
    /// - Parameters:
    ///   - uid: 사용자 식별자
    ///   - item: 삭제할 운동 기록
    func deleteRecord(uid: String, item: WorkoutRecord)
    
    /// 사용자의 모든 운동 기록을 삭제합니다.
    /// - Parameter uid: 사용자 식별자
    func deleteAllRecord(uid: String)
    
    func updateRecord(uid: String, item: WorkoutRecord)
}

