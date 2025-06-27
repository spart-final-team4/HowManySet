//
//  LiveActivityDefaultsName.swift
//  HowManySet
//
//  Created by 정근호 on 6/27/25.
//

import Foundation

/// LiveActivity 사용 시 쓰이는 리터럴 값 모음
final class LiveActivityDefaultsName {
    
    static let shared = LiveActivityDefaultsName()
    private init() {}

    let appGroupID = "group.com.eightroutes.HowManySet"
    
    let playAndPauseIndex = "PlayAndPauseRestIndex"
    let playAndPauseTimeStamp = "PlayAndPauseRestTimestamp"
    
    let setCompleteIndex = "SetCompleteIndex"
    let setCompleteTimeStamp = "SetCompleteTimestamp"
    
    let skipIndex = "SkipIndex"
    let skipTimeStamp = "SkipTimeStamp"
}

extension Notification.Name {
    static let playAndPauseRestEvent = Notification.Name("playAndPauseRestEvent")
    static let setCompleteEvent = Notification.Name("setCompleteEvent")
    static let skipEvent = Notification.Name("skipEvent")
}

