//
//  Notification+Name.swift
//  HowManySet
//
//  Created by 정근호 on 6/19/25.
//

import Foundation

extension Notification.Name {
    static let setCompleteFromLiveActivity = Notification.Name("setCompleteFromLiveActivity")
    static let stopWorkoutFromLiveActivity = Notification.Name("stopWorkoutFromLiveActivity")
    static let skipRestFromLiveActivity = Notification.Name("skipRestFromLiveActivity")
    static let playAndPauseRestFromLiveActivity = Notification.Name("playAndPauseRestFromLiveActivity")
}
