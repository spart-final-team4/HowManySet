//
//  HowManySetLiveActivityLiveActivity.swift
//  HowManySetLiveActivity
//
//  Created by 정근호 on 5/30/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct HowManySetLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct HowManySetLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HowManySetLiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

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
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension HowManySetLiveActivityAttributes {
    fileprivate static var preview: HowManySetLiveActivityAttributes {
        HowManySetLiveActivityAttributes(name: "World")
    }
}

extension HowManySetLiveActivityAttributes.ContentState {
    fileprivate static var smiley: HowManySetLiveActivityAttributes.ContentState {
        HowManySetLiveActivityAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: HowManySetLiveActivityAttributes.ContentState {
         HowManySetLiveActivityAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: HowManySetLiveActivityAttributes.preview) {
   HowManySetLiveActivityLiveActivity()
} contentStates: {
    HowManySetLiveActivityAttributes.ContentState.smiley
    HowManySetLiveActivityAttributes.ContentState.starEyes
}
