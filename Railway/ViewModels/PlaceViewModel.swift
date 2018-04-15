//
//  PlaceViewModel.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation

class PlaceViewModel {
    
    let carriageText: String
    let seatText: String
    
    init(_ place: Place) {
        carriageText = "\(place.carriage)"
        seatText = place.seat
    }
}
