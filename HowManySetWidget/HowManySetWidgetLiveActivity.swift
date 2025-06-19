//
//  HowManySetLiveActivityLiveActivity.swift
//  HowManySetLiveActivity
//
//  Created by 정근호 on 5/30/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HowManySetWidgetAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        // state
        /// 전체 운동 시간
        var workoutTime: Int
        
        // 운동 중 관련
        var isWorkingout: Bool
        var exerciseName: String
        var exerciseInfo: String
        
        // 휴식 중 관련
        var isResting: Bool
        var restSecondsRemaining: Int
        var isRestPaused: Bool
        
        // 세트 관련
        var currentSet: Int
        var totalSet: Int
        
        // 현재 코드 인덱스
        var currentIndex: Int
    }
    
    // Fixed non-changing properties about your activity go here!
    // attributes
}

struct HowManySetWidgetLiveActivity: Widget {
    
    private let buttonSize: CGFloat = 50
    private let restSecondsRemainigLabelSize: CGFloat = 46
    private let restLabel = "휴식"
    
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: HowManySetWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack() {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundStyle(.brand)
                        Text(String(context.state.workoutTime.toWorkOutTimeLabel()))
                            .foregroundStyle(.white)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .monospacedDigit()
                    }
                    // MARK: - 운동 중 contents
                    if !context.state.isResting {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(context.state.exerciseName)
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                Text(context.state.exerciseInfo)
                                    .font(.system(size: 16))
                                    .fontWeight(.regular)
                                    .foregroundStyle(Color("DBTypo"))
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 10) {
                                if #available(iOS 17.0, *) {
                                    Button(intent: SetCompleteIntent(index: context.state.currentIndex)) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.brand)
                                            .fontWeight(.bold)
                                            .font(.title3)
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(Circle().fill(Color("brandBackground")))
                                    .buttonStyle(.borderless)
                                } else {
                                    // Fallback on earlier versions
                                }
                                
                                if #available(iOS 17.0, *) {
                                    Button(intent: StopWorkoutIntent(index: context.state.currentIndex)) {
                                        Image(systemName: "xmark")
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                            .font(.title3)
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(Circle().fill(Color("RoundButtonBG")))
                                    .buttonStyle(.borderless)
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                        }
                    }
                    // MARK: - 휴식 중 contents
                    else {
                        HStack {
                            HStack(alignment: .lastTextBaseline, spacing: 5) {
                                Text(restLabel)
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.brand)
                                Text(context.state.restSecondsRemaining.toRestTimeLabel())
                                    .font(.system(size: restSecondsRemainigLabelSize))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .monospacedDigit()
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 10) {
                                if #available(iOS 17.0, *) {
                                    Button(intent: SkipRestIntent(index: context.state.currentIndex)) {
                                        Image(systemName: "forward.end.fill")
                                            .foregroundStyle(.brand)
                                            .fontWeight(.semibold)
                                            .font(.title3)
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(Circle().fill(Color("brandBackground")))
                                    .buttonStyle(.borderless)
                                } else {
                                    // Fallback on earlier versions
                                }
                                
                                if #available(iOS 17.0, *) {
                                    Button(intent: PlayAndPauseRestIntent()) {
                                        Image(systemName: context.state.isRestPaused ? "play.fill" : "pause.fill")
                                            .foregroundStyle(.white)
                                            .fontWeight(.semibold)
                                            .font(.title3)
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(Circle().fill(Color("RoundButtonBG")))
                                    .buttonStyle(.borderless)
                                } else {
                                    // Fallback on earlier versions
                                }

                            }
                        }
                    }
                    // MARK: - ProgressBar
                    SetProgressBarForLiveActivity(
                        totalSets: context.state.totalSet,
                        currentSet: context.state.currentSet
                    )
                    .frame(maxWidth: .infinity, maxHeight: 14)

                }//VStack
            }//VStack
            .padding(.all, 18)
            .frame(height: 170)
            .background(Color("Background"))
            
        } dynamicIsland: { context in
            // MARK: - DynamicIsland
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "dumbbell")
                        .foregroundStyle(.brand)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: "dumbbell")
                        .foregroundStyle(.brand)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Image(systemName: "dumbbell")
                        .foregroundStyle(.brand)
                    // more content
                }
            } compactLeading: {
                Image(systemName: "dumbbell")
                    .foregroundStyle(.brand)
            } compactTrailing: {
                Image(systemName: "dumbbell")
                    .foregroundStyle(.brand)
            } minimal: {
                Image(systemName: "dumbbell")
                    .foregroundStyle(.brand)
            }
            .keylineTint(.brand)
        }
    }
}

// MARK: - WorkoutDataForLiveActivity -> ContentState
extension HowManySetWidgetAttributes.ContentState {
    /// WorkoutDataForLiveActivity를 HowManySetWidgetAttributes.ContentState로 변환
    init(from data: WorkoutDataForLiveActivity) {
        self.workoutTime = data.workoutTime
        self.isWorkingout = data.isWorkingout
        self.exerciseName = data.exerciseName
        self.exerciseInfo = data.exerciseInfo
        self.isResting = data.isResting
        self.restSecondsRemaining = Int(data.restSecondsRemaining)
        self.isRestPaused = data.isRestPaused
        self.currentSet = data.currentSet
        self.totalSet = data.totalSet
        self.currentIndex = data.currentIndex
    }
}

extension HowManySetWidgetAttributes {
    fileprivate static var preview: HowManySetWidgetAttributes {
        HowManySetWidgetAttributes()
    }
}

extension HowManySetWidgetAttributes.ContentState {
    fileprivate static var workout: HowManySetWidgetAttributes.ContentState {
        HowManySetWidgetAttributes.ContentState(
            workoutTime: 5000,
            isWorkingout: true,
            exerciseName: "랫풀다운",
            exerciseInfo: "60kg x 10회",
            isResting: false,
            restSecondsRemaining: 0,
            isRestPaused: false,
            currentSet: 2,
            totalSet: 5,
            currentIndex: 0
        )
    }
    
    fileprivate static var rest: HowManySetWidgetAttributes.ContentState {
        HowManySetWidgetAttributes.ContentState(
            workoutTime: 5000,
            isWorkingout: false,
            exerciseName: "랫풀다운",
            exerciseInfo: "60kg x 10회",
            isResting: true,
            restSecondsRemaining: 30,
            isRestPaused: false,
            currentSet: 2,
            totalSet: 5,
            currentIndex: 0
        )
    }
}

@available(iOS 17.0, *)
#Preview("Notification", as: .content, using: HowManySetWidgetAttributes.preview) {
    HowManySetWidgetLiveActivity()
} contentStates: {
    HowManySetWidgetAttributes.ContentState.workout
    HowManySetWidgetAttributes.ContentState.rest
}
