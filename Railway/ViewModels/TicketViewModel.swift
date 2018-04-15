//
//  TicketViewModel.swift
//  Railway
//
//  Created by Евгений Соболь on 4/7/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TicketViewModel {

    var routeText: String
    var dateText: String

    init(_ ticket: Ticket) {
        let sourceName = ticket.sourceStation.name
        let destinationName = ticket.destinationStation.name
        routeText = sourceName + " - " + destinationName
        dateText = DateFormatters.longDateAndTime.string(from: ticket.departure)
        
    }
}
