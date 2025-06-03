//
//  WorkoutDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation

/// 운동 정보를 전송·저장할 때 사용하는 데이터 전송 객체(Data Transfer Object)입니다.
///
/// 주로 네트워크 계층이나 로컬 캐싱 계층과 도메인 계층 사이에서 데이터를 주고받을 때 활용됩니다.
struct WorkoutDTO {
    
    /// 운동 이름입니다.
    ///
    /// 예: `"벤치프레스"`, `"데드리프트"` 등
    let name: String
    
    /// 운동을 구성하는 세트 목록입니다.
    ///
    /// 각 요소는 `WorkoutSetDTO` 타입이며, 반복 수·무게 등의 세트 정보를 포함합니다.
    let sets: [WorkoutSetDTO]
    
    /// 세트 간 휴식 시간(초)입니다.
    ///
    /// 예: `90`이면 세트 사이에 90초 휴식
    let restTime: Int
    
    /// 운동에 대한 선택적 메모입니다.
    ///
    /// 예: `"폼 유지에 집중"`, `"최대 중량 도전"` 등
    let comment: String?
}

extension WorkoutDTO {
    
    /// DTO를 도메인 모델인 `Workout` 엔티티로 변환합니다.
    ///
    /// - Returns: `Workout` 타입 인스턴스
    func toEntity() -> Workout {
        return Workout(name: self.name,
                       sets: self.sets.map { $0.toEntity() },
                       restTime: self.restTime,
                       comment: self.comment)
    }
}
