//
//  RecordRepository.swift
//  HowManySet
//
//  Created by MJ Dev on 6/4/25.
//

import Foundation
import RxSwift

/// 운동 기록 저장 및 조회 기능을 제공하는 리포지토리 프로토콜입니다.
///
/// 데이터 저장소(로컬, 원격 등)와의 인터페이스를 정의합니다.
protocol RecordRepository {
    
    /// 주어진 사용자 ID에 해당하는 운동 기록을 저장합니다.
    ///
    /// - Parameters:
    ///   - uid: 운동 기록을 저장할 사용자의 고유 식별자
    ///   - item: 저장할 `WorkoutRecord` 객체
    func saveRecord(uid: String, item: WorkoutRecord)
    
    /// 주어진 사용자 ID에 해당하는 운동 기록 리스트를 비동기적으로 조회합니다.
    ///
    /// - Parameter uid: 운동 기록을 조회할 사용자의 고유 식별자
    /// - Returns: `Single`로 감싸진 `WorkoutRecord` 배열, 조회 성공 시 배열을 방출하고 실패 시 에러를 방출합니다.
    func fetchRecord(uid: String) -> Single<[WorkoutRecord]>
}
