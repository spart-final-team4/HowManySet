//
//  LiveActivityAppGroupBridge.swift
//  HowManySet
//
//  Created by 정근호 on 6/19/25.
//

import Foundation

final class LiveActivityAppGroupEventBridge {
    static let shared = LiveActivityAppGroupEventBridge()
    private let appGroupID = "group.com.eightroutes.HowManySet"

    private var lastHandledTimestamps: [String: TimeInterval] = [:]

    private init() {}

    func checkSetCompleteEvent(completion: (Int) -> Void) {
        checkEvent(indexKey: "SetCompleteIndex", timestampKey: "SetCompleteTimestamp", completion: completion)
    }

    func checkSkipRestEvent(completion: (Int) -> Void) {
        checkEvent(indexKey: "SkipRestIndex", timestampKey: "SkipRestTimestamp", completion: completion)
    }
    
    func checkPlayAndPauseRestEvent(completion: (Int) -> Void) {
        checkEvent(indexKey: "PlayAndPauseRestIndex", timestampKey: "PlayAndPauseRestTimestamp", completion: completion)
    }

    func checkStopWorkoutEvent(completion: () -> Void) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        let key = "StopWorkout"
        let timestampKey = "StopWorkoutTimestamp"
        let flag = defaults.bool(forKey: key)
        let timestamp = defaults.double(forKey: timestampKey)
        let lastTimestamp = lastHandledTimestamps[key] ?? 0
        guard flag, timestamp > lastTimestamp else { return }
        lastHandledTimestamps[key] = timestamp
        completion()
        defaults.removeObject(forKey: key)
        defaults.removeObject(forKey: timestampKey)
    }

    // 공통 인덱스 이벤트 처리
    private func checkEvent(indexKey: String, timestampKey: String, completion: (Int) -> Void) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        let index = defaults.integer(forKey: indexKey)
        let timestamp = defaults.double(forKey: timestampKey)
        let lastTimestamp = lastHandledTimestamps[indexKey] ?? 0
        guard index > 0, timestamp > lastTimestamp else { return }
        lastHandledTimestamps[indexKey] = timestamp
        completion(index)
        defaults.removeObject(forKey: indexKey)
        defaults.removeObject(forKey: timestampKey)
    }
}
