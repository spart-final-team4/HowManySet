//
//  StopRoutineIntent.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import AppIntents
import ActivityKit
//import WidgetKit

@available(iOSApplicationExtension 17.0, *)
struct StopWorkoutIntent: AppIntent {
    static var title: LocalizedStringResource = "운동 종료"

    func perform() async throws -> some IntentResult {
        
        NotificationCenter.default.post(name: .stopWorkoutFromLiveActivity, object: nil)
        return .result()
    }
}
