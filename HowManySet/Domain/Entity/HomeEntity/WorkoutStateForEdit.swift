//
//  WorkoutStateForEdit.swift
//  HowManySet
//
//  Created by 정근호 on 6/26/25.
//

import Foundation

/// 운동 편집 시 보낼 데이터 형식
struct WorkoutStateForEdit: Equatable, Codable {
    var currentRoutine: WorkoutRoutine
    var currentExcerciseName: String
    var currentUnit: String
    var currentWeightSet: [[String]]
}
