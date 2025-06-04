//
//  DeleteRoutineUseCase.swift
//  HowManySet
//
//  Created by MJ Dev on 6/2/25.
//

import Foundation

/// 운동 루틴을 삭제하는 유스케이스 구현체입니다.
///
/// `RoutineRepository`를 통해 특정 사용자의 운동 루틴을 삭제하는 기능을 제공합니다.
final class DeleteRoutineUseCase: DeleteRoutineUseCaseProtocol {
    
    /// 운동 루틴 데이터를 관리하는 리포지토리 객체
    private let repository: RoutineRepository
    
    /// 초기화 메서드
    ///
    /// - Parameter repository: 운동 루틴 저장소 프로토콜을 구현한 인스턴스
    init(repository: RoutineRepository) {
        self.repository = repository
    }
    
    /// 주어진 사용자 ID에 해당하는 운동 루틴을 삭제합니다.
    ///
    /// - Parameters:
    ///   - uid: 운동 루틴을 삭제할 사용자의 고유 식별자
    ///   - item: 삭제할 `WorkoutRoutine` 객체
    func execute(uid: String, item: WorkoutRoutine) {
        repository.deleteRoutine(uid: uid, item: item)
    }
}

