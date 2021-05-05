//
//  GetUpcomingTicketsIntentHandler.swift
//  RailwayIntentsExtension
//
//  Created by Евгений Соболь on 5.05.21.
//  Copyright © 2021 Евгений Соболь. All rights reserved.
//

import Intents

class GetUpcomingTicketsIntentHandler: NSObject, GetUpcomingTicketsIntentHandling {

    let databaseManager: DatabaseManager
    let calendar = Calendar.current

    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }

    func handle(intent: GetUpcomingTicketsIntent, completion: @escaping (GetUpcomingTicketsIntentResponse) -> Void) {
        guard let tickets = databaseManager.getUpcomingTickets() else {
            let response = GetUpcomingTicketsIntentResponse(code: .failure, userActivity: nil)
            response.error = "Нет подходящих билетов"
            completion(response)
            return
        }

        let resultTickets = tickets.map { TicketModel(ticket: $0, calendar: calendar) }
        let response = GetUpcomingTicketsIntentResponse(code: .success, userActivity: nil)
        response.result = resultTickets
        completion(response)
    }
}
