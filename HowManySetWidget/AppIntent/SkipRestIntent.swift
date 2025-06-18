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
    static var title: LocalizedStringResource = "휴식 스킵"

    func perform() async throws -> some IntentResult {
        
        NotificationCenter.default.post(
            name: .skipRestFromLiveActivity,
            object: nil
        )
        return .result()
    }
}
