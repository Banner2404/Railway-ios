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

    var tickets: [Ticket] = [] {
        didSet {
            updateTickets()
        }
    }
    @IBOutlet private var table: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        PhoneConnectivityManager.shared.delegate = self
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
    
    private func updateTickets() {
        table.setNumberOfRows(tickets.count, withRowType: "TicketExpandedRowController")
        print("Updating \(tickets.count)")
        for (index, ticket) in tickets.enumerated() {
            let row = table.rowController(at: index) as! TicketExpandedRowController
            row.sourceLabel.setText(ticket.sourceStation.name)
            row.destinationLabel.setText(ticket.destinationStation.name)
            let departute = DateFormatters.shortTime.string(from: ticket.departure)
            let arrival = DateFormatters.shortTime.string(from: ticket.arrival)
            row.timeLabel.setText(departute + " - " + arrival)
            let date = DateFormatters.longDate.string(from: ticket.departure)
            row.dateLabel.setText(date)
            guard let place = ticket.places.first else { continue }
            row.carriageLabel.setText(String(place.carriage))
            row.seatLabel.setText(place.seat)
        }
    }

}

//MARK: - PhoneConnectivityManagerDelegate
extension InterfaceController: PhoneConnectivityManagerDelegate {
    
    func phoneConnectivityManager(_ manager: PhoneConnectivityManager, didRecieve tickets: [Ticket]) {
        self.tickets = tickets
        updateTickets()
    }
}
