//
//  SmallWidgetView.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 8/8/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SmallWidgetView : View {
    var entry: TicketTimelineEntry

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(entry.departure, formatter: DateFormatters.shortDateAndTime)
                    .font(.system(size: 20))
                    .foregroundColor(Color(.text))
                Spacer()
            }
            PlaceView(carriage: entry.carriage, seat: entry.seat)
            Spacer()
        }
        .padding()
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(
            entry: TicketTimelineEntry(
                date: Date(),
                carriage: "5",
                seat: "34",
                departure: Date().addingTimeInterval(60 * 60 * 4)
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
