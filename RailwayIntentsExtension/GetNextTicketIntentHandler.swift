//
//  GetNextTicketIntentHandler.swift
//  RailwayIntentsExtension
//
//  Created by Евгений Соболь on 4.05.21.
//  Copyright © 2021 Евгений Соболь. All rights reserved.
//

import Intents

class GetNextTicketIntentHandler: NSObject, GetNextTicketIntentHandling {

    let databaseManager = DefaultDatabaseManager()
    let calendar = Calendar.current
    
    func handle(intent: GetNextTicketIntent, completion: @escaping (GetNextTicketIntentResponse) -> Void) {
        guard let ticket = databaseManager.getNextTicket() else {
            let response = GetNextTicketIntentResponse(code: .failure, userActivity: nil)
            response.error = "Нет подходящих билетов"
            completion(response)
            return
        }
        let displayName = "\(ticket.sourceStation.name) - \(ticket.destinationStation.name)"
        let resultTicket = TicketModel(identifier: nil, display: displayName)
        resultTicket.departureStation = ticket.sourceStation.name
        resultTicket.arrivalStation = ticket.destinationStation.name
        let components: Set<Calendar.Component> = Set(
            [.calendar, .era, .timeZone, .year,.month,.day,.hour,.minute,.second]
        )
        resultTicket.departureDate = calendar.dateComponents(components, from: ticket.departure)
        resultTicket.arrivalDate = calendar.dateComponents(components, from: ticket.arrival)
        resultTicket.places = ticket.places.map { place in
            return PlaceModel(place: place)
        }

        let response = GetNextTicketIntentResponse(code: .success, userActivity: nil)
        response.result = resultTicket
        completion(response)
    }
}

extension PlaceModel {

    convenience init(place: Place) {
        let displayName = "\(place.carriage) вагон \(place.seat) место"
        self.init(identifier: nil, display: displayName)
        self.carriage = NSNumber(value: place.carriage)
        self.seat = place.seat
    }
}
