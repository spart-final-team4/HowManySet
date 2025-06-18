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
    }

    // Fixed non-changing properties about your activity go here!
    // attributes
}

struct HowManySetWidgetLiveActivity: Widget {
    
    private let buttonSize: CGFloat = 50
    private let restSecondsRemainigLabelSize: CGFloat = 50
    private let restLabel = "휴식"
    
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: HowManySetWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack() {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundStyle(.brand)
                        Text(String(context.state.workoutTime.toWorkOutTimeLabel()))
                            .foregroundStyle(.white)
                            .font(.body)
                            .fontWeight(.bold)
                    }
                    Group {
                        // MARK: - 운동 중 contents
                        if context.state.isWorkingout {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(context.state.exerciseName)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                    Text(context.state.exerciseInfo)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.gray)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 10) {
                                    Button(action: {
                                        
                                    }) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.brand)
                                            .fontWeight(.heavy)
                                            .font(.title3)
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(.brandBackground)
                                    .clipShape(Circle())
                                    
                                    Button(action: {
                                        
                                    }) {
                                        Image(systemName: "xmark")
                                            .foregroundStyle(.white)
                                            .fontWeight(.heavy)
                                            .font(.title3)
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(.gray)
                                    .clipShape(Circle())
                                }
                            }
                            .frame(height: 50)
                        }
                        // MARK: - 휴식 중 contents
                        else if context.state.isResting {
                            HStack {
                                HStack(alignment: .lastTextBaseline, spacing: 5) {
                                    Text(restLabel)
                                        .font(.body)
                                        .foregroundStyle(.brand)
                                    Text(context.state.restSecondsRemaining.toRestTimeLabel())
                                        .font(.system(size: restSecondsRemainigLabelSize))
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 10) {
                                    Button(action: {
                                        
                                    }) {
                                        Image(systemName: "forward.end.fill")
                                            .foregroundStyle(.brand)
                                            .fontWeight(.semibold)
                                            .font(.title3)
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(.brandBackground)
                                    .clipShape(Circle())
                                    
                                    Button(action: {
                                        
                                    }) {
                                        Image(systemName: "pause.fill")
                                            .foregroundStyle(.white)
                                            .fontWeight(.semibold)
                                            .font(.title3)
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(.gray)
                                    .clipShape(Circle())
                                }
                            }
                            .frame(height: 50)
                        } else {
                            EmptyView()
                        }
                    }//Group
                    // MARK: - ProgressBar
                    SetProgressBarRepresentable(totalSets: 5, currentSet: 2)
                        .frame(maxWidth: .infinity, minHeight: 10, maxHeight: 10)
                }//VStack
            }//VStack
            .padding(.all, 20)
            .frame(height: 160)
            .background(.black)
            
        } dynamicIsland: { context in
            // MARK: - DynamicIsland
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("m")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
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
            totalSet: 5
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
             totalSet: 5
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
