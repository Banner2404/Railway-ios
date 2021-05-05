//
//  GetNextTicketIntentHandler.swift
//  RailwayIntentsExtension
//
//  Created by Евгений Соболь on 4.05.21.
//  Copyright © 2021 Евгений Соболь. All rights reserved.
//

import Intents

class GetNextTicketIntentHandler: NSObject, GetNextTicketIntentHandling {

    let databaseManager: DatabaseManager
    let calendar = Calendar.current

    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }
    
    func handle(intent: GetNextTicketIntent, completion: @escaping (GetNextTicketIntentResponse) -> Void) {
        guard let ticket = databaseManager.getNextTicket() else {
            let response = GetNextTicketIntentResponse(code: .failure, userActivity: nil)
            response.error = "Нет подходящих билетов"
            completion(response)
            return
        }

        let resultTicket = TicketModel(ticket: ticket, calendar: calendar)
        let response = GetNextTicketIntentResponse(code: .success, userActivity: nil)
        response.result = resultTicket
        completion(response)
    }
}
