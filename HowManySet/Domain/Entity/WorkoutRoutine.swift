//
//  WorkoutRoutine.swift
//  HowManySet
//
//  Created by MJ Dev on 6/2/25.
//

import Foundation

/// 하나의 운동 루틴을 나타내는 구조체입니다.
///
/// 루틴 이름과 그에 포함된 여러 개의 운동 목록을 포함합니다.
struct WorkoutRoutine {
    
    /// 운동 루틴의 이름입니다.
    ///
    /// 예: `"전신 루틴"`, `"상체 집중 루틴"` 등
    let name: String
    
    /// 루틴에 포함된 운동 목록입니다.
    ///
    /// 각 `Workout`은 루틴을 구성하는 개별 운동을 나타냅니다.
    let workouts: [Workout]
}

