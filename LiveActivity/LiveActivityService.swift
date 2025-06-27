//
//  LiveActivityService.swift
//  HowManySet
//
//  Created by 정근호 on 5/30/25.
//

import Foundation
import ActivityKit

final class LiveActivityService {
    
    static let shared = LiveActivityService()
    
    var activity: Activity<HowManySetWidgetAttributes>?
    
    init() {}
    
    func start(with data: WorkoutDataForLiveActivity) {
        let attributes = HowManySetWidgetAttributes()
        let contentState = HowManySetWidgetAttributes.ContentState(from: data)
        
        do {
            print("🎮 LiveActivity DO")
            let activityContent = ActivityContent(state: contentState, staleDate: nil)
            let activity = try Activity<HowManySetWidgetAttributes>.request(
                attributes: attributes,
                content: activityContent
            )
            self.activity = activity
            print("🎮 LiveActivity STARTED!: ", activity)
        } catch {
            print(error)
        }
    }
    
    func update(state: HowManySetWidgetAttributes.ContentState) {
        let content: ActivityContent<HowManySetWidgetAttributes.ContentState>
        content = ActivityContent(state: state, staleDate: nil)
        for activity in Activity<HowManySetWidgetAttributes>.activities {
            Task {
                
                await activity.update(content)
            }
        }
    }
    
    func stop() {
        Task {
            for activity in Activity<HowManySetWidgetAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
                print("🎮 LIVEACTIVITY 종료!")
                LiveActivityAppGroupEventBridge.shared.removeAppGroupEventValuesIfNeeded()
            }
        }
    }
}
