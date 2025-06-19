//
//  LiveActivityModel.swift
//  HowManySet
//
//  Created by 정근호 on 6/18/25.
//

import Foundation

/// LiveActivity에 필요한 데이터
public struct WorkoutDataForLiveActivity: Equatable, Codable, Hashable {
    let workoutTime: Int
    var isWorkingout: Bool
    var exerciseName: String
    var exerciseInfo: String
    var isResting: Bool
    var restSecondsRemaining: Float
    var isRestPaused: Bool
    var currentSet: Int
    var totalSet: Int
    var currentIndex: Int
}

