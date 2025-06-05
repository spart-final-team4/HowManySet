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
        var workoutTime: TimeInterval
        
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
        var entireSet: Int
    }

    // Fixed non-changing properties about your activity go here!
    // attributes
    var restLabel = "휴식"
}

struct HowManySetWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HowManySetWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                HStack {
                    Image(systemName: "timer")
                        .tint(.brand)
                    Text(String(context.state.workoutTime))
                }
                
                if context.state.isWorkingout {
                    // 운동 중
                    HStack {
                        VStack {
                            Text(context.state.exerciseName)
                            Text(context.state.exerciseInfo)
                        }
                        
                        HStack {
                            Button(action: {
                                
                            }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.brand)
                                    .frame(width: 44, height: 44)
                                    .background(.brand).opacity(0.3)
                                    .clipShape(Circle())
                            }
                            Button(action: {
                                
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(.gray)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                else if context.state.isResting {
                    // 휴식 중
                    HStack {
                        HStack {
                            Text(context.attributes.restLabel)
                            Text(String(context.state.restSecondsRemaining))
                        }
                        
                        HStack {
                            Button("CheckButton", systemImage: "checkmark") {
                                
                            }
                            .labelStyle(.iconOnly)
                            Button("XButton", systemImage: "xmark") {
                                
                            }
                            .labelStyle(.iconOnly)
                            .background(in: Circle())
                        }
                    }
                }
               
                // progressBar
                
            }
            .frame(height: 160)
            .activityBackgroundTint(Color.black)
            
        } dynamicIsland: { context in
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
                    Text("Bottom \(context.attributes.restLabel)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.attributes.restLabel)")
            } minimal: {
                Text(context.attributes.restLabel)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension HowManySetWidgetAttributes {
    fileprivate static var preview: HowManySetWidgetAttributes {
        HowManySetWidgetAttributes(restLabel: "휴식")
    }
}

extension HowManySetWidgetAttributes.ContentState {
    fileprivate static var workout: HowManySetWidgetAttributes.ContentState {
        HowManySetWidgetAttributes.ContentState(
            workoutTime: 1000,
            isWorkingout: true,
            exerciseName: "랫풀다운",
            exerciseInfo: "60kg x 10회",
            isResting: false,
            restSecondsRemaining: 0,
            isRestPaused: false,
            currentSet: 2,
            entireSet: 5
        )
     }
     
     fileprivate static var rest: HowManySetWidgetAttributes.ContentState {
         HowManySetWidgetAttributes.ContentState(
             workoutTime: 1000,
             isWorkingout: false,
             exerciseName: "랫풀다운",
             exerciseInfo: "60kg x 10회",
             isResting: true,
             restSecondsRemaining: 30,
             isRestPaused: false,
             currentSet: 2,
             entireSet: 5
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
