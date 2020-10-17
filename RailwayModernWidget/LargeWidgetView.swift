//
//  LargeWidgetView.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 10/17/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {

    var ticket: TicketTimelineEntry.TicketInfo

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(ticket.sourceStation)
                .primaryText()
                .leftAligned()
            Text(ticket.destinationStation)
                .primaryText()
                .leftAligned()
            Divider()
            TicketTimeView(
                departureDate: ticket.departure,
                arrivalDate: ticket.arrival)
            Text(ticket.departure, formatter: DateFormatters.longDate)
                .font(.system(size: 18))
                .foregroundColor(Color(.text))
                .opacity(0.5)
                .leftAligned()
            Divider()
            HPlaceView(carriage: ticket.carriage, seat: ticket.seat)
                .padding(.top, 5)
            Divider()
            if ticket.notes.isEmpty {
                Text("Нет заметок")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .leftAligned()
            } else {
                Text(ticket.notes)
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                    .leftAligned()
            }

            Spacer()
        }
    }
}

struct LargeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        LargeWidgetView(ticket: .preview)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
