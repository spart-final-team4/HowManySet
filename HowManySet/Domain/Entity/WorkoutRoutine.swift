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
    
    /// 세트 간의 휴식 시간(초)입니다.
    ///
    /// 예: `60`이면 세트 간 휴식 시간이 60초입니다.
    let restTime: Int
    
}

extension WorkoutRoutine {
    static let mockData: [WorkoutRoutine] = [
        WorkoutRoutine(
            name: "전신 루틴",
            workouts: [
                Workout.mockData[0], // 벤치프레스
                Workout.mockData[1], // 스쿼트
                Workout.mockData[2]  // 데드리프트
            ], restTime: 5
        ),
        WorkoutRoutine(
            name: "상체 집중 루틴",
            workouts: [
                Workout.mockData[0], // 벤치프레스
                Workout.mockData[3], // 오버헤드 프레스
                Workout.mockData[4]  // 랫풀다운
            ], restTime: 5
        ),
        WorkoutRoutine(
            name: "하체 강화 루틴",
            workouts: [
                Workout.mockData[1], // 스쿼트
                Workout.mockData[2]  // 데드리프트
            ], restTime: 5
        )
    ]
}
