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
    static var title: LocalizedStringResource = "Stop Routine"

    func perform() async throws -> some IntentResult {
        print("StopWorkoutIntent")
        
        // [운동 종료 메서드]
        
        return .result()
    }
}
