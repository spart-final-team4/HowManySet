//
//  FSUpdateRoutineUseCase.swift
//  HowManySet
//
//  Created by GO on 6/19/25.
//

import Foundation

/// Firestore 기반 운동 루틴을 업데이트하는 유스케이스 구현체입니다.
/// FSRoutineRepository를 통해 루틴 업데이트 로직을 실행합니다.
final class FSUpdateRoutineUseCase: UpdateRoutineUseCaseProtocol {
    
    /// Firestore 운동 루틴 관련 데이터 처리를 담당하는 저장소
    private let repository: RoutineRepository

    /// 유스케이스 초기화 메서드
    /// - Parameter repository: Firestore 운동 루틴을 업데이트할 저장소 객체
    init(repository: RoutineRepository) {
        self.repository = repository
    }

    /// 특정 사용자의 운동 루틴을 Firestore에서 업데이트합니다.
    /// - Parameters:
    ///   - uid: 사용자 식별자
    ///   - item: 업데이트할 운동 루틴
    func execute(uid: String, item: WorkoutRoutine) {
        repository.updateRoutine(uid: uid, item: item)
    }
}
