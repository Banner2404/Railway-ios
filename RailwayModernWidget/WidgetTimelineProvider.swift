//
//  WidgetTimelineProvider.swift
//  Railway
//
//  Created by Евгений Соболь on 8/8/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import Foundation
import WidgetKit

struct WidgetTimelineProvider: TimelineProvider {

    let databaseManager = DefaultDatabaseManager()

    func placeholder(in context: Context) -> TicketTimelineEntry {
        print("Placeholder")
        return TicketTimelineEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (TicketTimelineEntry) -> ()) {
        print("Snapshot")
        if let ticket = databaseManager.getNextTicket() {
            print(ticket)
            let entry = timelineEntry(for: ticket, displayDate: Date())
            completion(entry)
        } else {
            print("No ticket")
            completion(TicketTimelineEntry.placeholder)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TicketTimelineEntry>) -> ()) {
        print("Timeline")
        var entries: [TicketTimelineEntry] = []
        let tickets = getTickets()
        var previousTicket: Ticket?
        for ticket in tickets {
            let displayDate = previousTicket?.arrival.addingTimeInterval(60 * 10) ?? Date()
            entries.append(timelineEntry(for: ticket, displayDate: displayDate))
            previousTicket = ticket
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func timelineEntry(for ticket: Ticket, displayDate: Date) -> TicketTimelineEntry {
        let carriage: String
        if let carriageInt = ticket.places.first?.carriage {
            carriage = String(carriageInt)
        } else {
            carriage = "-"
        }
        return TicketTimelineEntry(
            date: displayDate,
            carriage: carriage,
            seat: ticket.places.first?.seat ?? "-",
            departure: ticket.departure
        )
    }

    private func getTickets() -> [Ticket] {
        let tickets = databaseManager.loadTickets()
        return tickets
            .filter { $0.arrival > Date() }
            .sorted { $0.departure < $1.departure }
    }
}
