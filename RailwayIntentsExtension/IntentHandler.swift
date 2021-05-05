//
//  IntentHandler.swift
//  RailwayIntentsExtension
//
//  Created by Евгений Соболь on 4.05.21.
//  Copyright © 2021 Евгений Соболь. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        return GetNextTicketIntentHandler()
    }
    
}
