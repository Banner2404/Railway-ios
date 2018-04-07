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
    
    private static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM, yyyy h:mm"
        return dateFormatter
    }()

    init(_ ticket: Ticket) {
        let sourceName = ticket.sourceStation.name
        let destinationName = ticket.destinationStation.name
        routeText = sourceName + " - " + destinationName
        dateText = TicketViewModel.dateFormatter.string(from: ticket.departure)
        
    }
}
