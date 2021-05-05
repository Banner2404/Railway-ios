//
//  PlaceModelExtension.swift
//  RailwayIntentsExtension
//
//  Created by Евгений Соболь on 5.05.21.
//  Copyright © 2021 Евгений Соболь. All rights reserved.
//

import Foundation

extension PlaceModel {

    convenience init(place: Place) {
        let displayName = "\(place.carriage) вагон \(place.seat) место"
        self.init(identifier: nil, display: displayName)
        self.carriage = NSNumber(value: place.carriage)
        self.seat = place.seat
    }
}
