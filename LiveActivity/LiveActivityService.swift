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
    
    func startQuicklyThenUpdate(with data: WorkoutDataForLiveActivity) {
        // 최소한의 초기 상태로 빠르게 시작
        let initialContentState = WorkoutDataForLiveActivity(
            workoutTime: 0,
            isWorkingout: true,
            exerciseName: "",
            exerciseInfo: "",
            currentRoutineCompleted: false,
            isResting: false,
            restSecondsRemaining: 0,
            isRestPaused: false,
            currentSet: 0,
            totalSet: 0,
            currentIndex: 0,
            accumulatedWorkoutTime: 0,
            accumulatedRestRemaining: 0,
            restStartDate: nil,
            workoutStartDate: Date()
        )
        start(with: initialContentState)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let fullContentState = HowManySetWidgetAttributes.ContentState(from: data)
            self.update(state: fullContentState)
        }
    }
    
    func update(state: HowManySetWidgetAttributes.ContentState) {
        let content: ActivityContent<HowManySetWidgetAttributes.ContentState>
        content = ActivityContent(state: state, staleDate: nil)
        Task {
            for activity in Activity<HowManySetWidgetAttributes>.activities {
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
