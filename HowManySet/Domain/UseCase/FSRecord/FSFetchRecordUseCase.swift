//
//  FSFetchRecordUseCase.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation
import RxSwift

/// Firestore 기반 운동 기록을 조회하는 유스케이스 구현체입니다.
/// FSRecordRepository를 통해 특정 사용자의 운동 기록 목록을 비동기적으로 가져오는 기능을 제공합니다.
final class FSFetchRecordUseCase: FetchRecordUseCaseProtocol {
    
    /// Firestore 운동 기록 데이터를 관리하는 리포지토리 객체
    private let repository: RecordRepository
    
    /// 초기화 메서드
    /// - Parameter repository: Firestore 운동 기록 저장소 프로토콜을 구현한 인스턴스
    init(repository: RecordRepository) {
        self.repository = repository
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 기록 리스트를 Firestore에서 비동기적으로 조회합니다.
    /// - Parameter uid: 운동 기록을 조회할 사용자의 고유 식별자
    /// - Returns: `Single`로 감싸진 `WorkoutRecord` 배열, 조회 성공 시 배열을 방출하고 실패 시 에러를 방출합니다.
    func execute(uid: String) -> Single<[WorkoutRecord]> {
        return repository.fetchRecord(uid: uid)
    }
}
