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

    var ticket: TicketTimelineEntry.TicketInfo

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(ticket.destinationStation)
                .primaryText()
                .leftAligned()
            Text(ticket.departure, formatter: DateFormatters.shortDateAndTime)
                .primaryText()
                .leftAligned()
            HPlaceView(carriage: ticket.carriage, seat: ticket.seat)
                .padding(.top, 5)
        }
    }
}

struct MediumWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidgetView(
            ticket: .preview
        )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
