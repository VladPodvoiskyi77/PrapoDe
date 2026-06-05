//
//  PrepoWidgetLiveActivity.swift
//  PrepoWidget
//
//  Created by test on 05.02.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PrepoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PrepoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrepoWidgetAttributes.self) { context in
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

extension PrepoWidgetAttributes {
    fileprivate static var preview: PrepoWidgetAttributes {
        PrepoWidgetAttributes(name: "World")
    }
}

extension PrepoWidgetAttributes.ContentState {
    fileprivate static var smiley: PrepoWidgetAttributes.ContentState {
        PrepoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PrepoWidgetAttributes.ContentState {
         PrepoWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PrepoWidgetAttributes.preview) {
   PrepoWidgetLiveActivity()
} contentStates: {
    PrepoWidgetAttributes.ContentState.smiley
    PrepoWidgetAttributes.ContentState.starEyes
}
