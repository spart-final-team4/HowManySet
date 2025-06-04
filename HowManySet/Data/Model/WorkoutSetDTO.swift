//
//  WorkoutSetDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation

/// 운동 세트 정보를 전송하거나 저장할 때 사용하는 데이터 전송 객체(Data Transfer Object)입니다.
///
/// 세트별 무게, 단위, 반복 횟수 정보를 담고 있으며, 네트워크 또는 로컬 저장소 계층과 도메인 계층 간 데이터 전달에 사용됩니다.
struct WorkoutSetDTO {
    
    /// 세트에서 사용한 무게입니다.
    ///
    /// 예: `50.0` (단위는 `unit`에 따라 다름)
    let weight: Double
    
    /// 무게 단위입니다.
    ///
    /// 예: `"kg"`, `"lb"` 등
    let unit: String
    
    /// 반복 횟수입니다.
    ///
    /// 예: `12` 회
    let reps: Int
}

extension WorkoutSetDTO {
    
    /// DTO를 도메인 모델인 `WorkoutSet` 객체로 변환합니다.
    ///
    /// - Returns: `WorkoutSet` 타입의 도메인 모델 인스턴스
    func toEntity() -> WorkoutSet {
        return WorkoutSet(weight: self.weight,
                          unit: self.unit,
                          reps: self.reps)
    }
}

