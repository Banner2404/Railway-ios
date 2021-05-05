//
//  TicketModelExtension.swift
//  RailwayIntentsExtension
//
//  Created by Евгений Соболь on 5.05.21.
//  Copyright © 2021 Евгений Соболь. All rights reserved.
//

import Foundation

extension TicketModel {

    convenience init(ticket: Ticket, calendar: Calendar) {
        let displayName = "\(ticket.sourceStation.name) - \(ticket.destinationStation.name)"
        self.init(identifier: nil, display: displayName)
        self.departureStation = ticket.sourceStation.name
        self.arrivalStation = ticket.destinationStation.name
        let components: Set<Calendar.Component> = Set(
            [.calendar, .era, .timeZone, .year,.month,.day,.hour,.minute,.second]
        )
        self.departureDate = calendar.dateComponents(components, from: ticket.departure)
        self.arrivalDate = calendar.dateComponents(components, from: ticket.arrival)
        self.places = ticket.places.map { place in
            return PlaceModel(place: place)
        }

    }
}
