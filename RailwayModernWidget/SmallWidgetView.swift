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
        ZStack {
            Color(.cardBackground)
            Group {
                if let ticket = entry.ticket {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(ticket.departure, formatter: DateFormatters.shortDateAndTime)
                                .font(.system(size: 20))
                                .foregroundColor(Color(.text))
                            Spacer()
                        }
                        VPlaceView(carriage: ticket.carriage, seat: ticket.seat)
                    }
                } else {
                    NoTicketsView()
                }
            }
            .padding()
        }
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(
            entry: TicketTimelineEntry(
                date: Date(),
                ticket: .init(
                    carriage: "5",
                    seat: "34",
                    departure: Date().addingTimeInterval(60 * 60 * 4)
                )
            )
        )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        SmallWidgetView(
            entry: TicketTimelineEntry(
                date: Date(),
                ticket: nil
            )
        )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
