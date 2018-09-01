//
//  TicketExpandedRowController.swift
//  Railway Watch Extension
//
//  Created by Евгений Соболь on 8/11/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import WatchKit

class TicketExpandedRowController: NSObject {
    
    var maxNumberOfPlaces: Int {
        return placeGroups.count
    }
    var numberOfPlaces: Int = 0 {
        didSet {
            placeGroups.enumerated().forEach {
                $0.element.setHidden($0.offset >= numberOfPlaces)
            }
        }
    }
    var carriageLabels: [WKInterfaceLabel] {
        return [carriageLabel1, carriageLabel2, carriageLabel3]
    }
    var seatLabels: [WKInterfaceLabel] {
        return [seatLabel1, seatLabel2, seatLabel3]
    }
    @IBOutlet var sourceLabel: WKInterfaceLabel!
    @IBOutlet var destinationLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var dateLabel: WKInterfaceLabel!
    
    private var placeGroups: [WKInterfaceGroup] {
        return [placeGroup1, placeGroup2, placeGroup3]
    }
    @IBOutlet private var placeGroup1: WKInterfaceGroup!
    @IBOutlet private var placeGroup2: WKInterfaceGroup!
    @IBOutlet private var placeGroup3: WKInterfaceGroup!
    @IBOutlet private var carriageLabel1: WKInterfaceLabel!
    @IBOutlet private var carriageLabel2: WKInterfaceLabel!
    @IBOutlet private var carriageLabel3: WKInterfaceLabel!
    @IBOutlet private var seatLabel1: WKInterfaceLabel!
    @IBOutlet private var seatLabel2: WKInterfaceLabel!
    @IBOutlet private var seatLabel3: WKInterfaceLabel!
    
}
