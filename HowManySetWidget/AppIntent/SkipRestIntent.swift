//
//  SkipRestIntent.swift
//  HowManySet
//
//  Created by 정근호 on 6/2/25.
//

import AppIntents
import ActivityKit
import WidgetKit

@available(iOSApplicationExtension 17.0, *)
public struct SkipRestIntent: AppIntent, LiveActivityIntent {
    public static var title: LocalizedStringResource = "휴식 스킵"
    public static var description = IntentDescription("휴식 스킵 버튼(스킵 후 다음 세트로 넘어감)")
    @Parameter(title: "현재 운동 인덱스")
    public var index: Int?
    
    public init() {}

    public init(index: Int) {
        self.index = index
    }

    public func perform() async throws -> some IntentResult {
        
        let sharedDefaults = UserDefaults(suiteName: "group.com.eightroutes.HowManySet")
        sharedDefaults?.set(index, forKey: "SkipRestIndex")
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "SkipRestTimestamp")
        sharedDefaults?.synchronize()
        return .result()
    }
}
