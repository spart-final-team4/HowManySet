//
//  HowManySetIntentExtension.swift
//  HowManySetIntentExtension
//
//  Created by 정근호 on 6/19/25.
//

import AppIntents

struct HowManySetIntentExtension: AppIntent {
    static var title: LocalizedStringResource { "HowManySetIntentExtension" }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
