//
//  RecordRepositoryImpl.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift

/// `RecordRepository` 프로토콜을 구현한 운동 기록 저장소 클래스입니다.
///
/// 실제 데이터 소스(예: 데이터베이스, 네트워크 등)와 연동하여 운동 기록을 저장하고 조회하는 기능을 제공합니다.
final class RecordRepositoryImpl: RecordRepository {
    
    /// 주어진 사용자 ID에 해당하는 운동 기록을 저장합니다.
    ///
    /// - Parameters:
    ///   - uid: 운동 기록을 저장할 사용자의 고유 식별자
    ///   - item: 저장할 `WorkoutRecord` 객체
    func saveRecord(uid: String, item: WorkoutRecord) {
        // TODO: 운동 기록 저장 구현
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 기록 리스트를 비동기적으로 조회합니다.
    ///
    /// - Parameter uid: 운동 기록을 조회할 사용자의 고유 식별자
    /// - Returns: `Single`로 감싸진 `WorkoutRecord` 배열, 조회 성공 시 배열을 방출하고 실패 시 에러를 방출합니다.
    func fetchRecord(uid: String) -> Single<[WorkoutRecord]> {
        return Single.create { observer in
            // TODO: 운동 기록 조회 구현
            
            // 현재는 빈 배열을 반환하는 예시입니다.
            observer(.success([]))
            
            return Disposables.create()
        }
    }
}
