//
//  PlayAndPauseRestIntent.swift
//  HowManySet
//
//  Created by 정근호 on 6/2/25.
//

import AppIntents
import ActivityKit
import WidgetKit

@available(iOSApplicationExtension 17.0, *)
public struct PlayAndPauseRestIntent: AppIntent, LiveActivityIntent {
    
    public static var title: LocalizedStringResource = LocalizedStringResource("휴식 중지 재개")
    public static var description = IntentDescription(LocalizedStringResource("휴식 중지 및 재개 버튼"))
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

        updatedState.isRestPaused.toggle()

        // 휴식 PlayAndPause
        if updatedState.isRestPaused { // Pause 클릭 시
            // 남은 휴식 시간을 restTime에 저장
            let remaining = updatedState.restEndDate?.timeIntervalSince(Date.now) ?? 0
            updatedState.restTime = max(0, Int(remaining))
        } else { // Play 클릭 시
            // 현재 시각을 시작 시각으로 설정
            updatedState.restStartDate = Date.now
        }
                
        // 변경된 content로 업데이트
        let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
        await activity.update(updatedContent, alertConfiguration: nil)
        
        // UserDefaults 업데이트
        let sharedDefaults = UserDefaults(suiteName: LiveActivityDefaultsName.shared.appGroupID)
        sharedDefaults?.set(index, forKey: LiveActivityDefaultsName.shared.playAndPauseIndex)
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: LiveActivityDefaultsName.shared.playAndPauseTimeStamp)

        return .result()
    }
}

