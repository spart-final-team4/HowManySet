//
//  Workout.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation

/// 운동 정보를 나타내는 구조체입니다.
///
/// 이 구조체는 특정 운동의 이름, 세트 목록, 세트 간 휴식 시간, 그리고 선택적인 코멘트를 포함합니다.
struct Workout {
    
    /// 운동 이름입니다.
    ///
    /// 예: `"벤치프레스"`, `"스쿼트"` 등
    let name: String
    
    /// 운동에 포함된 세트 목록입니다.
    ///
    /// `WorkoutSet` 타입의 배열로, 각 세트의 반복 횟수, 무게 등을 포함할 수 있습니다.
    let sets: [WorkoutSet]
    
    /// 세트 간의 휴식 시간(초)입니다.
    ///
    /// 예: `60`이면 세트 간 휴식 시간이 60초입니다.
    let restTime: Int
    
    /// 운동에 대한 메모 또는 코멘트입니다. 선택 사항입니다.
    ///
    /// 예: `"폼에 집중하기"`, `"마지막 세트는 최대 중량"` 등
    let comment: String?
}
