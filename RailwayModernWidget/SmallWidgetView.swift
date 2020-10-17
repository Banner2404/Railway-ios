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
    var ticket: TicketTimelineEntry.TicketInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(ticket.departure, formatter: DateFormatters.shortDateAndTime)
                .primaryText()
                .leftAligned()
            VPlaceView(carriage: ticket.carriage, seat: ticket.seat)
        }
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(
            ticket: .preview
        )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
