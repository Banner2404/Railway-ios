//
//  TodayViewController.swift
//  RailwayWidget
//
//  Created by Евгений Соболь on 7/30/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    private let database = DefaultDatabaseManager()
    @IBOutlet private weak var placeView: PlaceView!
    @IBOutlet private weak var dateLabel: UILabel!
    
    private lazy var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.minute]
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = false
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        guard let ticket = database.getNextTicket() else {
            completionHandler(.noData)
            return
        }
        if ticket.departure.timeIntervalSinceNow > 60 * 60 * 2 {
            setupFullDate(with: ticket)
        } else if ticket.departure.timeIntervalSinceNow > 0 {
            setupDepartureDate(with: ticket)
        } else {
            setupArrivalDate(with: ticket)
        }
        if let place = ticket.places.first {
            placeView.carriageLabel.text = String(place.carriage)
            placeView.seatLabel.text = place.seat
        }
        completionHandler(NCUpdateResult.newData)
    }
    
    func setupFullDate(with ticket: Ticket) {
        dateLabel.text = DateFormatters.longDateAndTime.string(from: ticket.departure)
    }
    
    func setupDepartureDate(with ticket: Ticket) {
        let time = DateFormatters.shortTime.string(from: ticket.departure)
        let interval = dateComponentsFormatter.string(from: Date(), to: ticket.departure) ?? ""
        dateLabel.text = "Отправление через \(interval), \(time)"
    }
    
    func setupArrivalDate(with ticket: Ticket) {
        let time = DateFormatters.shortTime.string(from: ticket.arrival)
        let interval = dateComponentsFormatter.string(from: Date(), to: ticket.arrival) ?? ""
        dateLabel.text = "Прибытие через \(interval), \(time)"
    }
    
}
