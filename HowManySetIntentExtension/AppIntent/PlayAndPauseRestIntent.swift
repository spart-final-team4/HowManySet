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
    
//        // 휴식 PlayAndPause
//        if updatedState.isRestPaused { // Pause 클릭 시
//            // 남은 휴식 시간 처리
//            let elapsed = Date().timeIntervalSince(updatedState.restStartDate ?? Date())
//            updatedState.restSecondsRemaining -= Int(elapsed)
//            updatedState.restStartDate = nil
//        } else { // Play 클릭 시
//            // 휴식 시작 시간 초기화
//            updatedState.restStartDate = Date()
//        }
        updatedState.isRestPaused.toggle()
                
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

