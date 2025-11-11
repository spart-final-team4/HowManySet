//
//  SetCompleteIntent.swift
//  HowManySet
//
//  Created by 정근호 on 6/2/25.
//

import AppIntents
import ActivityKit
import WidgetKit

@available(iOSApplicationExtension 17.0, *)
public struct SetCompleteIntent: AppIntent, LiveActivityIntent {
    
    public static var title: LocalizedStringResource = LocalizedStringResource("세트 완료")
    public static var description = IntentDescription(LocalizedStringResource("세트 완료 버튼"))
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

        // 운동시간 처리
//        let elapsedTime = Date().timeIntervalSince(updatedState.workoutStartDate)
//        updatedState.workoutTime += Int(elapsedTime)
        
        // 세트, 휴식 상태 처리
        updatedState.currentSet += 1
        updatedState.isResting = true
        updatedState.restStartDate = Date()
        
        // 변경된 content로 업데이트
        let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
        await activity.update(updatedContent, alertConfiguration: nil)
        
        // UserDefaults 업데이트
        let sharedDefaults = UserDefaults(suiteName: LiveActivityDefaultsName.shared.appGroupID)
        sharedDefaults?.set(index, forKey: LiveActivityDefaultsName.shared.setCompleteIndex)
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: LiveActivityDefaultsName.shared.setCompleteTimeStamp)
        
        return .result()
    }
}
