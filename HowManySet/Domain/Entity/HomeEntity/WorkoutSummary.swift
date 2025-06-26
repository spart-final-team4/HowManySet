//
//  WorkoutSummary.swift
//  HowManySet
//
//  Created by 정근호 on 6/26/25.
//

import Foundation

/// 운동 완료 UI에 보여질 운동 요약 통계 정보
struct WorkoutSummary: Codable {
    let routineName: String
    let date: Date
    let routineDidProgress: Float
    let totalTime: Int
    let exerciseDidCount: Int
    let setDidCount: Int
    let routineMemo: String?
}
