//
//  MediumWidgetView.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 10/17/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {

    var entry: TicketTimelineEntry

    var body: some View {
        ZStack {
            Color(.cardBackground)
            Group {
                if let ticket = entry.ticket {
                    VStack(alignment: .center, spacing: 8) {
                        HStack {
                            Text(ticket.arrivalStation)
                                .font(.system(size: 20))
                                .foregroundColor(Color(.text))
                            Spacer()
                        }
                        HStack {
                            Text(ticket.departure, formatter: DateFormatters.shortDateAndTime)
                                .font(.system(size: 20))
                                .foregroundColor(Color(.text))
                            Spacer()
                        }
                        HPlaceView(carriage: ticket.carriage, seat: ticket.seat)
                            .padding(.top, 5)
                    }
                } else {
                    NoTicketsView()
                }
            }
            .padding()
        }
    }
}

struct MediumWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidgetView(
            entry: TicketTimelineEntry.preview
        )
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        MediumWidgetView(
            entry: TicketTimelineEntry(
                date: Date(),
                ticket: nil
            )
        )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
