//
//  UpdateRoutineUseCase.swift
//  HowManySet
//
//  Created by MJ Dev on 6/9/25.
//

import Foundation

/// 운동 루틴을 업데이트하는 유스케이스 구현체입니다.
/// RoutineRepository를 통해 루틴 업데이트 로직을 실행합니다.
final class UpdateRoutineUseCase: UpdateRoutineUseCaseProtocol {
    
    /// 운동 루틴 관련 데이터 처리를 담당하는 저장소
    private let repository: RoutineRepository

    /// 유스케이스 초기화 메서드
    /// - Parameter repository: 운동 루틴을 업데이트할 저장소 객체
    init(repository: RoutineRepository) {
        self.repository = repository
    }

    /// 특정 사용자의 운동 루틴을 업데이트합니다.
    /// - Parameters:
    ///   - item: 업데이트할 운동 루틴
    func execute(item: WorkoutRoutine) {
        repository.updateRoutine(item: item)
    }
}

