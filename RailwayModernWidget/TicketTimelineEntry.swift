//
//  TicketTimelineEntry.swift
//  RailwayModernWidgetExtension
//
//  Created by Евгений Соболь on 8/8/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import WidgetKit
import SwiftUI

struct TicketTimelineEntry: TimelineEntry {

    let date: Date
    let ticket: TicketInfo?

    static var placeholder: TicketTimelineEntry {
        return TicketTimelineEntry(
            date: Date(),
            ticket: TicketInfo(
                carriage: "-",
                seat: "-",
                departure: Date().addingTimeInterval(60 * 60 * 24)
            )
        )
    }

    struct TicketInfo {
        let carriage: String
        let seat: String
        let departure: Date
    }
}
