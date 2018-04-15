//
//  Place.swift
//  Railway
//
//  Created by Евгений Соболь on 4/7/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation

struct Place {
    let id: String
    let carriage: Int
    let seat: String
    
    init(carriage: Int, seat: String) {
        self.id = UUID().uuidString
        self.carriage = carriage
        self.seat = seat
    }
}
