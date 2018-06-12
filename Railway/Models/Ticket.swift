//
//  Ticket.swift
//  Railway
//
//  Created by Евгений Соболь on 4/3/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation

struct Ticket {
    var id: String
    let sourceStation: Station
    let destinationStation: Station
    let departure: Date
    let arrival: Date
    let places: [Place]

    init(sourceStation: Station, destinationStation: Station, departure: Date, arrival: Date, places: [Place]) {
        self.id = UUID().uuidString
        self.sourceStation = sourceStation
        self.destinationStation = destinationStation
        self.departure = departure
        self.arrival = arrival
        self.places = places
    }
}
