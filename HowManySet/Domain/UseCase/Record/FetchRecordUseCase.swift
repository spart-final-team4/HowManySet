//
//  FetchRecordUseCase.swift
//  HowManySet
//
//  Created by MJ Dev on 6/2/25.
//

import Foundation
import RxSwift

/// 운동 기록을 조회하는 유스케이스 구현체입니다.
///
/// `RecordRepository`를 통해 특정 사용자의 운동 기록 목록을 비동기적으로 가져오는 기능을 제공합니다.
final class FetchRecordUseCase: FetchRecordUseCaseProtocol {
    
    /// 운동 기록 데이터를 관리하는 리포지토리 객체
    private let repository: RecordRepository
    
    /// 초기화 메서드
    ///
    /// - Parameter repository: 운동 기록 저장소 프로토콜을 구현한 인스턴스
    init(repository: RecordRepository) {
        self.repository = repository
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 기록 리스트를 비동기적으로 조회합니다.
    /// - Returns: `Single`로 감싸진 `WorkoutRecord` 배열, 조회 성공 시 배열을 방출하고 실패 시 에러를 방출합니다.
    func execute(uid: String = "") -> Single<[WorkoutRecord]> {
        return repository.fetchRecord()
    }
}
