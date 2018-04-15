//
//  TicketDetailsViewModel.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation

class TicketDetailsViewModel {
    
    let stationsText: String
    let departureTimeText: String
    let arrivalTimeText: String
    let dateText: String
    
    init(_ ticket: Ticket) {
        stationsText = "\(ticket.sourceStation.name) - \(ticket.destinationStation.name)"
        departureTimeText = DateFormatters.shortTime.string(from: ticket.departure)
        arrivalTimeText = DateFormatters.shortTime.string(from: ticket.arrival)
        dateText = DateFormatters.longDate.string(from: ticket.departure)
    }
}