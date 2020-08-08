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
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }
}

struct RailwayModernWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(
            entry:
                TicketTimelineEntry(
                    date: Date(),
                    carriage: "1",
                    seat: "2",
                    departure: Date().addingTimeInterval(60 * 60)
                )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
//        SmallWidgetView(entry: TicketTimelineEntry(date: Date(), carriage: "1", seat: "2"))
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//        SmallWidgetView(entry: TicketTimelineEntry(date: Date(), carriage: "1", seat: "2"))
//            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
