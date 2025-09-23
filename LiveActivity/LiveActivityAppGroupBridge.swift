//
//  LiveActivityAppGroupBridge.swift
//  HowManySet
//
//  Created by 정근호 on 6/19/25.
//

import Foundation

final class LiveActivityAppGroupEventBridge {
    
    static let shared = LiveActivityAppGroupEventBridge()
    
    private var lastHandledTimestamps: [String: TimeInterval] = [:]
    private var lastHandledStopWorkoutTimestamp: Double = 0
    
    private init() {}
    
    func checkSetCompleteEvent(completion: (Int) -> Void) {
        checkEvent(indexKey: LiveActivityDefaultsName.shared.setCompleteIndex, timestampKey: LiveActivityDefaultsName.shared.setCompleteTimeStamp, completion: completion)
    }
    
    func checkSkipRestEvent(completion: (Int) -> Void) {
        checkEvent(indexKey: LiveActivityDefaultsName.shared.skipIndex, timestampKey: LiveActivityDefaultsName.shared.skipTimeStamp, completion: completion)
    }
    
    func checkPlayAndPauseRestEvent(completion: (Int) -> Void) {
        checkEvent(indexKey: LiveActivityDefaultsName.shared.playAndPauseIndex, timestampKey: LiveActivityDefaultsName.shared.playAndPauseTimeStamp, completion: completion)
    }

//    func checkStopWorkoutEvent(completion: () -> Void) {
//        guard let defaults = UserDefaults(suiteName: LiveActivityDefaultsName.shared.appGroupID) else { return }
//        let flag = defaults.bool(forKey: "StopWorkout")
//        let timestamp = defaults.double(forKey: "StopWorkoutTimestamp")
//        if flag && timestamp > lastHandledStopWorkoutTimestamp {
//            print("StopWorkout 감지됨: \(timestamp)")
//            lastHandledStopWorkoutTimestamp = timestamp
//            completion()
//            defaults.removeObject(forKey: "StopWorkout")
//            defaults.removeObject(forKey: "StopWorkoutTimestamp")
//        }
//    }
    
    // 공통 인덱스 이벤트 처리
    private func checkEvent(indexKey: String, timestampKey: String, completion: (Int) -> Void) {
        guard let defaults = UserDefaults(suiteName: LiveActivityDefaultsName.shared.appGroupID) else { return }
        let index = defaults.integer(forKey: indexKey)
        let timestamp = defaults.double(forKey: timestampKey)
        let lastTimestamp = lastHandledTimestamps[indexKey] ?? 0
//        print("🎬 timeStamp: \(timestamp), lastTimeStamp: \(lastTimestamp)")
//        print("🎬 DEFAULTS: \(defaults)")
        // 중복 실행 방지
        guard timestamp > lastTimestamp else { return }
        lastHandledTimestamps[indexKey] = timestamp
        completion(index)
        defaults.removeObject(forKey: indexKey)
        defaults.removeObject(forKey: timestampKey)
    }
    
    /// 앱 시작 시 기존 운동 진행 정보 관련 defaults들 제거
    func removeAppGroupEventValuesIfNeeded() {
        if let defaults = UserDefaults(suiteName: LiveActivityDefaultsName.shared.appGroupID) {
            defaults.removeObject(forKey: LiveActivityDefaultsName.shared.setCompleteIndex)
            defaults.removeObject(forKey: LiveActivityDefaultsName.shared.setCompleteTimeStamp)
            defaults.removeObject(forKey: LiveActivityDefaultsName.shared.skipIndex)
            defaults.removeObject(forKey: LiveActivityDefaultsName.shared.skipTimeStamp)
            defaults.removeObject(forKey: LiveActivityDefaultsName.shared.playAndPauseIndex)
            defaults.removeObject(forKey: LiveActivityDefaultsName.shared.playAndPauseTimeStamp)
//            defaults.removeObject(forKey: "StopWorkout")
//            defaults.removeObject(forKey: "StopWorkoutTimestamp")
        }
    }
}
