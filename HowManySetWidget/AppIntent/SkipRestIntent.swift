//
//  SkipRestIntent.swift
//  HowManySet
//
//  Created by 정근호 on 6/2/25.
//

import AppIntents
import ActivityKit
//import WidgetKit

@available(iOSApplicationExtension 17.0, *)
struct SkipRestIntent: AppIntent {
    static var title: LocalizedStringResource = "Skip Rest"

    func perform() async throws -> some IntentResult {
        print("SkipRestIntent")
        
        // [휴식 스킵 메서드]
        
        return .result()
    }
}
