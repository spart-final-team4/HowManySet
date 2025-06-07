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
struct PlayRoutineIntent: AppIntent {
    static var title: LocalizedStringResource = "Play Routine"

    func perform() async throws -> some IntentResult {
        print("PlayRoutineIntent")
        
        // [운동 재개 메서드]
        
        return .result()
    }
}
