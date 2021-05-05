//
//  IntentHandler.swift
//  RailwayIntentsExtension
//
//  Created by Евгений Соболь on 4.05.21.
//  Copyright © 2021 Евгений Соболь. All rights reserved.
//

import Intents

class IntentHandler: INExtension {

    let database = DefaultDatabaseManager()

    override func handler(for intent: INIntent) -> Any {
        switch intent {
        case is GetNextTicketIntent:
            return GetNextTicketIntentHandler(databaseManager: database)
        case is GetUpcomingTicketsIntent:
            return GetUpcomingTicketsIntentHandler(databaseManager: database)
        default:
            fatalError("Unsupported intent")
        }
    }
    
}
