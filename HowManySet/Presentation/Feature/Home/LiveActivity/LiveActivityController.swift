//
//  LiveActivityController.swift
//  HowManySet
//
//  Created by 정근호 on 6/18/25.
//

import Foundation
import ActivityKit

class LiveActivityController {
    
    func updateLiveActivity(with data: WorkoutDataForLiveActivity) {
        let attributes = HowManySetWidgetAttributes(workout: "workout")
        let contentState = HowManySetWidgetAttributes.ContentState(
            workoutTime: data.workoutTime,
            isWorkingout: data.isWorkingout,
            exerciseName: data.exerciseName,
            exerciseInfo: data.exerciseInfo,
            isResting: data.isResting,
            restSecondsRemaining: Int(data.restSecondsRemaining),
            isRestPaused: data.isRestPaused,
            currentSet: data.currentSet,
            totalSet: data.totalSet
        )

        if let activity = Activity<HowManySetWidgetAttributes>.activities.first {
            Task {
                await activity.update(using: contentState)
            }
        }
    }
    
    func startLiveActivity(with data: WorkoutDataForLiveActivity) {
        
        let attributes = HowManySetWidgetAttributes(workout: "workout")
        
        let initialState = HowManySetWidgetAttributes.ContentState(
            workoutTime: data.workoutTime,
            isWorkingout: data.isWorkingout,
            exerciseName: data.exerciseName,
            exerciseInfo: data.exerciseInfo,
            isResting: data.isResting,
            restSecondsRemaining: Int(data.restSecondsRemaining),
            isRestPaused: data.isRestPaused,
            currentSet: data.currentSet,
            totalSet: data.totalSet
        )
        
        _ = try? Activity<HowManySetWidgetAttributes>.request(attributes: attributes, contentState: initialState)
    }

    func endLiveActivity() {
        if let activity = Activity<HowManySetWidgetAttributes>.activities.first {
            Task {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
}
