//
//  PauseRoutineIntent.swift
//  HowManySet
//
//  Created by 정근호 on 6/2/25.
//

import AppIntents
import ActivityKit
//import WidgetKit

@available(iOSApplicationExtension 17.0, *)
struct PauseRoutineIntent: AppIntent {
    static var title: LocalizedStringResource = "Pause Routine"

    func perform() async throws -> some IntentResult {
        print("PauseRoutineIntent")
        
        // [운동 중지 메서드]
        
        return .result()
    }
}
