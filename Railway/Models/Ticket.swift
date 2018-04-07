//
//  Ticket.swift
//  Railway
//
//  Created by Евгений Соболь on 4/3/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation

struct Ticket {
    let sourceStation: Station
    let destinationStation: Station
    let departure: Date
    let arrival: Date
    let places: [Place]
}
