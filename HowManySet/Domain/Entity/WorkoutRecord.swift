//
//  WorkoutRecord.swift
//  HowManySet
//
//  Created by MJ Dev on 6/3/25.
//

import Foundation

/// 사용자의 운동 기록을 나타내는 구조체입니다.
///
/// 하나의 운동 루틴 수행에 대한 총 소요 시간, 실제 운동 시간, 날짜, 코멘트 등의 정보를 포함합니다.
struct WorkoutRecord {
    
    /// 수행한 운동 루틴입니다.
    ///
    /// `WorkoutRoutine` 타입으로, 어떤 루틴을 수행했는지에 대한 정보를 담고 있습니다.
    let workoutRoutine: WorkoutRoutine
    
    /// 운동에 소요된 총 시간(초)입니다.
    ///
    /// 준비 시간, 세트 간 휴식 시간 등을 포함한 전체 운동 세션 시간입니다.
    let totalTime: Int
    
    /// 실제 운동 수행 시간(초)입니다.
    ///
    /// 세트 수행 시간만 합산한 값입니다.
    let workoutTime: Int
    
    /// 운동에 대한 메모 또는 코멘트입니다. 선택 사항입니다.
    ///
    /// 예: `"컨디션 좋았음"`, `"폼 개선 필요"` 등
    let comment: String?
    
    /// 운동을 수행한 날짜입니다.
    ///
    /// 기록이 저장된 날짜 및 시간 정보를 포함합니다.
    let date: Date
}

// MARK: - WorkoutRecord mockData
extension WorkoutRecord {
    static let mockData: [WorkoutRecord] = [
        WorkoutRecord(
            workoutRoutine: WorkoutRoutine.mockData[0], // 전신 루틴
            totalTime: 3600, // 1시간
            workoutTime: 3000, // 50분
            comment: "컨디션 좋았음",
            date: Date() // 오늘
        ),
        WorkoutRecord(
            workoutRoutine: WorkoutRoutine.mockData[1], // 상체 루틴
            totalTime: 2700, // 45분
            workoutTime: 2400, // 40분
            comment: nil,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date() // 어제
        ),
        WorkoutRecord(
            workoutRoutine: WorkoutRoutine.mockData[2], // 하체 루틴
            totalTime: 1800, // 30분
            workoutTime: 1500, // 25분
            comment: "폼 개선 필요",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date() // 그제
        )
    ]
}
