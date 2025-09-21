//
//  SkipIntent.swift
//  HowManySet
//
//  Created by 정근호 on 6/2/25.
//

import AppIntents
import ActivityKit
import WidgetKit

@available(iOSApplicationExtension 17.0, *)
public struct SkipIntent: AppIntent, LiveActivityIntent {
    
    public static var title: LocalizedStringResource = LocalizedStringResource("스킵")
    public static var description = IntentDescription(LocalizedStringResource("휴식 시간 있을 시 휴식 스킵 / 휴식 시간 0일시 세트 스킵"))
    @Parameter(title: LocalizedStringResource("현재 운동 인덱스"))
    public var index: Int?
    
    public init() {}

    public init(index: Int) {
        self.index = index
    }

    public func perform() async throws -> some IntentResult {

        guard let activity = Activity<HowManySetWidgetAttributes>.activities.first else {
            return .result()
        }
        
        var updatedState = activity.content.state
        
        // Skip 로직 처리
        updatedState.isResting = false
        updatedState.restStartDate = nil
        updatedState.workoutStartDate = Date()
        
        // 변경된 content로 업데이트
        let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
        await activity.update(updatedContent, alertConfiguration: nil)
        
        // UserDefaults 업데이트
        let sharedDefaults = UserDefaults(suiteName: LiveActivityDefaultsName.shared.appGroupID)
        sharedDefaults?.set(index, forKey: LiveActivityDefaultsName.shared.skipIndex)
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: LiveActivityDefaultsName.shared.skipTimeStamp)

        return .result()
    }
}
