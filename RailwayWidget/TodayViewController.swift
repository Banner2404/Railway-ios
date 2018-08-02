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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        guard let ticket = database.getNextTicket() else {
            completionHandler(.noData)
            return
        }
        dateLabel.text = DateFormatters.longDateAndTime.string(from: ticket.departure)
        if let place = ticket.places.first {
            placeView.carriageLabel.text = String(place.carriage)
            placeView.seatLabel.text = place.seat
        }
        completionHandler(NCUpdateResult.newData)
    }
    
}
