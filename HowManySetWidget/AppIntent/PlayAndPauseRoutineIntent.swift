//
//  PlayRoutineIntent.swift
//  HowManySet
//
//  Created by 정근호 on 6/2/25.
//

import AppIntents
import ActivityKit
//import WidgetKit

@available(iOSApplicationExtension 17.0, *)
struct PlayAndPauseRoutineIntent: AppIntent {
    static var title: LocalizedStringResource = "휴식 중지 재개"
    @Parameter(title: "현재 운동 인덱스") var index: Int

    func perform() async throws -> some IntentResult {
        
        NotificationCenter.default.post(
            name: .playAndPauseRestFromLiveActivity,
            object: nil,
            userInfo: ["index":index]
        )
        return .result()
    }
}
