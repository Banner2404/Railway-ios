//
//  InterfaceController.swift
//  Railway Watch Extension
//
//  Created by Евгений Соболь on 8/11/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet private var table: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        print("Interface awake")
        super.awake(withContext: context)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTickets), name: .ticketsDidUpdate, object: nil)
        updateTickets()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @objc
    private func updateTickets() {
        let tickets = TicketsStorage.shared.tickets
        table.setNumberOfRows(tickets.count, withRowType: "TicketExpandedRowController")
        print("Updating \(tickets.count)")
        for (index, ticket) in tickets.enumerated() {
            let row = table.rowController(at: index) as! TicketExpandedRowController
            row.sourceLabel.setText(ticket.sourceStation.name)
            row.destinationLabel.setText(ticket.destinationStation.name)
            let departute = DateFormatters.shortTime.string(from: ticket.departure)
            let arrival = DateFormatters.shortTime.string(from: ticket.arrival)
            row.timeLabel.setText(departute + " - " + arrival)
            let date = DateFormatters.longDateShortMonth.string(from: ticket.departure)
            row.dateLabel.setText(date)
            setupPlaces(for: row, ticket: ticket)
        }
    }
    
    private func setupPlaces(for row: TicketExpandedRowController, ticket: Ticket) {
        row.numberOfPlaces = ticket.places.count
        let displayedPlaces = ticket.places.prefix(row.maxNumberOfPlaces)
        displayedPlaces.enumerated().forEach {
            row.carriageLabels[$0.offset].setText(String($0.element.carriage))
            row.seatLabels[$0.offset].setText(String($0.element.seat))
        }
    }

}
