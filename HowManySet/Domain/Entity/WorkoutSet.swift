//
//  WorkoutSet.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation

/// 운동 세트 하나를 나타내는 구조체입니다.
///
/// 세트별 무게, 단위, 반복 횟수를 포함합니다.
struct WorkoutSet: Hashable, Codable {
    
    /// 세트에서 사용한 무게입니다.
    ///
    /// 예: `40.0` (단위는 `unit`에 따라 달라짐)
    let weight: Double
    
    /// 무게의 단위입니다.
    ///
    /// 예: `"kg"`, `"lb"` 등
    var unit: String
    
    /// 반복 횟수입니다.
    ///
    /// 해당 세트에서 운동을 수행한 횟수입니다. 예: `10`
    let reps: Int
}
