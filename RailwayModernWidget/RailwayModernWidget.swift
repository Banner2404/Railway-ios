//
//  RailwayModernWidget.swift
//  RailwayModernWidget
//
//  Created by Евгений Соболь on 8/8/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct RailwayModernWidget: Widget {
    let kind: String = "RailwayModernWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetTimelineProvider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct RailwayModernWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(
            entry:
                TicketTimelineEntry.preview
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        WidgetView(
            entry:
                TicketTimelineEntry.preview
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        WidgetView(
            entry:
                TicketTimelineEntry.preview
        )
        .previewContext(WidgetPreviewContext(family: .systemLarge))
        WidgetView(
            entry:
                TicketTimelineEntry.placeholder
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        WidgetView(
            entry:
                TicketTimelineEntry.placeholder
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        WidgetView(
            entry:
                TicketTimelineEntry.placeholder
        )
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
