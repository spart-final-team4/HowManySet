//
//  SkipSetIntent.swift
//  HowManySet
//
//  Created by 정근호 on 6/2/25.
//

import AppIntents
import ActivityKit
//import WidgetKit

@available(iOSApplicationExtension 17.0, *)
struct SkipSetIntent: AppIntent {
    static var title: LocalizedStringResource = "Skip Set"

    func perform() async throws -> some IntentResult {
        print("SkipSetIntent")
        
        // [세트 스킵 메서드]
        
        return .result()
    }
}
