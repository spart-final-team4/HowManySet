//
//  StopRoutineIntent.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

// TODO: - 현재 LiveActivity에서 운동 종료는 미사용 (아마 추후 개선 예정)
//import AppIntents
//import ActivityKit
//import WidgetKit
//
//@available(iOSApplicationExtension 17.0, *)
//public struct StopWorkoutIntent: AppIntent, LiveActivityIntent {
//    public static var title: LocalizedStringResource = "운동 종료"
//    public static var description = IntentDescription("운동 종료 버튼(클릭 시 앱에서 Alert)")
//    @Parameter(title: "현재 운동 인덱스") 
//    public var index: Int?
//    
//    public init() {}
//
//    public init(index: Int?) {
//        self.index = index
//    }
//
//    public func perform() async throws -> some IntentResult {
//        
//        let sharedDefaults = UserDefaults(appGroupID: "group.com.eightroutes.HowManySet")
//        sharedDefaults?.set(index, forKey: "StopWorkoutIndex")
//        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: "StopWorkoutTimeStamp") 
//        sharedDefaults?.synchronize()
//        return .result()
//    }
//}
