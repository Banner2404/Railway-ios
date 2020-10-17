//
//  WidgetView.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 10/17/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import SwiftUI
import WidgetKit

struct WidgetView : View {

    var entry: TicketTimelineEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color(.cardBackground)
            Group {
                if let ticket = entry.ticket {
                    switch family {
                    case .systemSmall:
                        SmallWidgetView(ticket: ticket)
                    case .systemMedium:
                        MediumWidgetView(ticket: ticket)
                    case .systemLarge:
                        LargeWidgetView(ticket: ticket)
                    default:
                        NoTicketsView()
                    }
                } else {
                    NoTicketsView()
                }
            }.padding()
        }
    }
}
