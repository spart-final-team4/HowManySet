//
//  SkipSetIntent.swift
//  HowManySet
//
//  Created by 정근호 on 6/2/25.
//

import AppIntents
import ActivityKit
import WidgetKit

@available(iOSApplicationExtension 17.0, *)
public struct SetCompleteIntent: AppIntent, ControlConfigurationIntent, LiveActivityIntent {
    public static var title: LocalizedStringResource = "세트 완료"
    public static var description = IntentDescription("세트 완료 버튼")
    @Parameter(title: "현재 운동 인덱스")
    public var index: Int?
    
    public init() {}

    public func perform() async throws -> some IntentResult {
        print("[Intent] perform 호출! index: \(String(describing: index))")
        let sharedDefaults = UserDefaults(suiteName: "group.com.eightroutes.HowManySet")
        sharedDefaults?.set(index, forKey: "SetCompleteIndex")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "SetCompleteTimestamp")
        sharedDefaults?.synchronize()
        return .result()
    }
}
