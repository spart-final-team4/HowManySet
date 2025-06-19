//
//  PlayRoutineIntent.swift
//  HowManySet
//
//  Created by 정근호 on 6/2/25.
//

import AppIntents
import ActivityKit
import WidgetKit

@available(iOSApplicationExtension 17.0, *)
public struct PlayAndPauseRestIntent: AppIntent, ControlConfigurationIntent, LiveActivityIntent {
    public static var title: LocalizedStringResource = "휴식 중지 재개"
    public static var description = IntentDescription("휴식 중지 및 재개 버튼")
    @Parameter(title: "현재 운동 인덱스")
    public var index: Int?
    
    public init() {}
    
    public func perform() async throws -> some IntentResult {
        
        let sharedDefaults = UserDefaults(suiteName: "group.com.eightroutes.HowManySet")
        sharedDefaults?.set(index, forKey: "PlayAndPauseRestIndex")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "PlayAndPauseRestTimestamp")
        sharedDefaults?.synchronize()
        return .result()
    }
}
