//
//  DeleteAllRecordUseCase.swift
//  HowManySet
//
//  Created by MJ Dev on 6/9/25.
//

import Foundation

/// 사용자의 모든 운동 기록을 삭제하는 유스케이스 구현체입니다.
/// RecordRepository를 통해 실제 데이터 삭제 로직을 실행합니다.
final class DeleteAllRecordUseCase: DeleteAllRecordUseCaseProtocol {
    
    /// 운동 기록 삭제를 처리할 저장소
    private let repository: RecordRepository

    /// 유스케이스 초기화 메서드
    /// - Parameter repository: 운동 기록 삭제 기능을 가진 저장소 객체
    init(repository: RecordRepository) {
        self.repository = repository
    }

    /// 사용자의 모든 운동 기록을 삭제합니다.
    func execute(uid: String?) {
        repository.deleteAllRecord(uid: uid)
    }
}

