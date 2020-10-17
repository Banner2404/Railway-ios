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
                departure: Date().addingTimeInterval(60 * 60 * 24),
                arrivalStation: "-"
            )
        )
    }

    static var preview: TicketTimelineEntry {
        return TicketTimelineEntry(
            date: Date(),
            ticket: TicketInfo(
                carriage: "12",
                seat: "42",
                departure: Date().addingTimeInterval(60 * 60 * 24),
                arrivalStation: "Минск-Пассажирский"
            )
        )
    }

    struct TicketInfo {
        let carriage: String
        let seat: String
        let departure: Date
        let arrivalStation: String
    }
}
