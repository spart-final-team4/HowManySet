//
//  WorkoutSetDTO.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation
import RealmSwift

/// 운동 세트의 정보를 나타내는 Realm 객체입니다.
/// 무게, 단위, 반복 횟수를 포함합니다.
final class WorkoutSetDTO: Object {
    /// 세트에서 들어올린 무게입니다.
    @Persisted var weight: Double

    /// 무게의 단위입니다. 예: "kg", "lb"
    @Persisted var unit: String

    /// 해당 세트에서 수행한 반복 횟수입니다.
    @Persisted var reps: Int

    /// 주어진 값들로 `WorkoutSetDTO` 객체를 초기화합니다.
    /// - Parameters:
    ///   - weight: 들어올린 무게
    ///   - unit: 무게의 단위
    ///   - reps: 반복 횟수
    convenience init(
        weight: Double,
        unit: String,
        reps: Int
    ) {
        self.init()
        self.weight = weight
        self.unit = unit
        self.reps = reps
    }
}

extension WorkoutSetDTO {
    /// DTO 객체를 도메인 모델인 `WorkoutSet`으로 변환합니다.
    /// - Returns: 동일한 값을 갖는 `WorkoutSet` 객체
    func toEntity() -> WorkoutSet {
        return WorkoutSet(weight: self.weight,
                          unit: self.unit,
                          reps: self.reps)
    }
}

extension WorkoutSetDTO {
    /// 도메인 모델 `WorkoutSet`을 기반으로 `WorkoutSetDTO`를 초기화합니다.
    /// - Parameter entity: 변환할 `WorkoutSet` 객체
    convenience init(entity: WorkoutSet) {
        self.init()
        self.weight = entity.weight
        self.unit = entity.unit
        self.reps = entity.reps
    }
}
