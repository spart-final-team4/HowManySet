//
//  LiveActivityModel.swift
//  HowManySet
//
//  Created by 정근호 on 6/18/25.
//

import Foundation

/// LiveActivity에 필요한 데이터
public struct WorkoutDataForLiveActivity: Equatable, Codable, Hashable {

    var workoutStartDate: Date?
    var isWorkingout: Bool
    var isWorkoutPaused: Bool

    var exerciseName: String
    var exerciseInfo: String
    var currentRoutineCompleted: Bool

    var restStartDate: Date?
    var liveRestTime: Float
    var restRemainingTimeInHome: Float
    var isResting: Bool
    var isRestPaused: Bool

    var currentSet: Int
    var totalSet: Int
    var currentIndex: Int
}
