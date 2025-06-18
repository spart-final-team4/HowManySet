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
    @Parameter(title: "현재 운동 인덱스") var index: Int
    
    func perform() async throws -> some IntentResult {
        
        let sharedDefaults = UserDefaults(suiteName: "group.com.eightroutes.HowManySet")
        sharedDefaults?.set(index, forKey: "CurrentIndex")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "CurrentTimeStamp") 
        sharedDefaults?.synchronize()
        return .result()
    }
}
