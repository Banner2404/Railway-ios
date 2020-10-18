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
            ticket: TicketInfo.placeholder
        )
    }

    static var preview: TicketTimelineEntry {
        return TicketTimelineEntry(
            date: Date(),
            ticket: TicketInfo.preview
        )
    }

    static var empty: TicketTimelineEntry {
        return TicketTimelineEntry(
            date: Date(),
            ticket: nil
        )
    }

    struct TicketInfo {
        let carriage: String
        let seat: String
        let departure: Date
        let arrival: Date
        let sourceStation: String
        let destinationStation: String
        let notes: String
        let isPlaceholder: Bool

        static var preview: TicketInfo {
            return TicketInfo(
                carriage: "12",
                seat: "42",
                departure: Date(),
                arrival: Date().addingTimeInterval(60 * 60 * 4),
                sourceStation: "Ивацевичи",
                destinationStation: "Минск-Пассажирский",
                notes: "Паспорт\nТелефон",
                isPlaceholder: false
            )
        }

        static var placeholder: TicketInfo {
            return TicketInfo(
                carriage: "10",
                seat: "10",
                departure: Date(),
                arrival: Date().addingTimeInterval(60 * 60 * 4),
                sourceStation: "Ивацевичи",
                destinationStation: "Минск-Пассажирский",
                notes: "Паспорт\nТелефон",
                isPlaceholder: true
            )
        }
    }
}
