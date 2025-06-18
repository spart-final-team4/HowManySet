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
    @Parameter(title: "현재 운동 인덱스") var index: Int
    
    func perform() async throws -> some IntentResult {
        
        let sharedDefaults = UserDefaults(suiteName: "group.com.eightroutes.HowManySet")
        sharedDefaults?.set(index, forKey: "SkipRestIndex")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "SkipRestTimestamp")
        sharedDefaults?.synchronize()
        return .result()
    }
}
