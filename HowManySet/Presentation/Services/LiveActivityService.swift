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
    
    private init() {}
    
    func start(with data: WorkoutDataForLiveActivity) {
        guard activity == nil else { return }
        let attributes = HowManySetWidgetAttributes()
        let contentState = HowManySetWidgetAttributes.ContentState(
            workoutTime: data.workoutTime,
            isWorkingout: data.isWorkingout,
            exerciseName: data.exerciseName,
            exerciseInfo: data.exerciseInfo,
            isResting: data.isResting,
            restSecondsRemaining: Int(data.restSecondsRemaining),
            isRestPaused: data.isRestPaused,
            currentSet: data.currentSet,
            totalSet: data.totalSet)
        
        do {
            let activityContent = ActivityContent(state: contentState, staleDate: nil)
            let activity = try Activity<HowManySetWidgetAttributes>.request(
                attributes: attributes,
                content: activityContent
            )
            self.activity = activity
            print("Activity: ", activity)
        } catch {
            print(error)
        }
    }
    
    func update(state: HowManySetWidgetAttributes.ContentState) {
        Task {
            let content: ActivityContent<HowManySetWidgetAttributes.ContentState>
            content = ActivityContent(state: state, staleDate: nil)
            for activity in Activity<HowManySetWidgetAttributes>.activities {
                await activity.update(content)
            }
        }
    }
    
    func stop() {
        
        Task {
            guard activity == nil else { return }
            await self.activity?.end(nil, dismissalPolicy: .immediate)
        }
    }
}
