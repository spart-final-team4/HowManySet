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
        guard timestamp > lastTimestamp else { return }
        lastHandledTimestamps[indexKey] = timestamp
        completion(index)
    }
    
    /// 앱 시작 시 기존 운동 진행 정보 관련 defaults들 제거
    func removeAppGroupEventValuesIfNeeded() {
        if let defaults = UserDefaults(suiteName: "group.com.eightroutes.HowManySet") {
            defaults.removeObject(forKey: "SetCompleteIndex")
            defaults.removeObject(forKey: "SetCompleteTimestamp")
            defaults.removeObject(forKey: "SkipRestIndex")
            defaults.removeObject(forKey: "SkipRestTimestamp")
            defaults.removeObject(forKey: "PlayAndPauseRestIndex")
            defaults.removeObject(forKey: "PlayAndPauseRestTimestamp")
            defaults.removeObject(forKey: "StopWorkout")
            defaults.removeObject(forKey: "StopWorkoutTimestamp")
        }
    }
}
