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
    
    var sourceName: String
    
    init(_ ticket: Ticket) {
        sourceName = ticket.sourceStation.name
    }
}
