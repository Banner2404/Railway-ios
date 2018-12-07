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
    private var ticket: Ticket?
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var noTicketsLabel: UILabel!
    @IBOutlet private weak var stackViewContainer: UIView!
    
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
        let latestTicket = database.getNextTicket()
        ticket = latestTicket
        updateInterface(with: ticket)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            preferredContentSize = maxSize
        case .expanded:
            let size = stackViewContainer.systemLayoutSizeFitting(CGSize(width: 1000, height: 1000))
            preferredContentSize = size
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let newTicket = database.getNextTicket()
        
        if newTicket == nil && self.ticket == nil {
            completionHandler(.noData)
            return
        }
        ticket = newTicket
        updateInterface(with: ticket)
        completionHandler(.newData)
    }
    
    func updateInterface(with ticket: Ticket?) {
        guard let ticket = ticket else {
            stackView.isHidden = true
            noTicketsLabel.isHidden = false
            extensionContext?.widgetLargestAvailableDisplayMode = .compact
            return
        }
        stackView.isHidden = false
        noTicketsLabel.isHidden = true
        if ticket.departure.timeIntervalSinceNow > 60 * 60 * 2 {
            setupFullDate(with: ticket)
        } else if ticket.departure.timeIntervalSinceNow > 0 {
            setupDepartureDate(with: ticket)
        } else {
            setupArrivalDate(with: ticket)
        }
        extensionContext?.widgetLargestAvailableDisplayMode = ticket.places.count > 1 ? .expanded : .compact
        setupPlaceViews(with: ticket)
    }
    
    func setupFullDate(with ticket: Ticket) {
        dateLabel.text = DateFormatters.longDateAndTime.string(from: ticket.departure).capitalized
    }
    
    func setupDepartureDate(with ticket: Ticket) {
        let time = DateFormatters.shortTime.string(from: ticket.departure)
        let interval = dateComponentsFormatter.string(from: Date(), to: ticket.departure) ?? ""
        let departure = NSLocalizedString("Отправление через", comment: "")
        dateLabel.text = "\(departure) \(interval), \(time)"
    }
    
    func setupArrivalDate(with ticket: Ticket) {
        let time = DateFormatters.shortTime.string(from: ticket.arrival)
        let interval = dateComponentsFormatter.string(from: Date(), to: ticket.arrival) ?? ""
        let arrival = NSLocalizedString("Прибытие через", comment: "")
        dateLabel.text = "\(arrival) \(interval), \(time)"
    }
    
    func setupPlaceViews(with ticket: Ticket) {
        stackView.arrangedSubviews
            .filter { $0 is PlaceView }
            .forEach {
                stackView.removeArrangedSubview($0)
                $0.removeFromSuperview() }
        
        for place in ticket.places {
            let placeView = PlaceView(frame: .zero)
            placeView.carriageLabel.text = String(place.carriage)
            placeView.seatLabel.text = place.seat
            placeView.backgroundView.isHidden = true
            stackView.addArrangedSubview(placeView)
        }
        
    }

    
}
