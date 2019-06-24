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

    private lazy var timeLeftFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.minute, .hour]
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

    @IBAction func widgetTapAction(_ sender: Any) {
        guard let url = URL(string: "ticks://open") else { return }
        extensionContext?.open(url, completionHandler: nil)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            preferredContentSize = maxSize
        case .expanded:
            let size = stackViewContainer.systemLayoutSizeFitting(CGSize(width: 1000, height: 1000))
            preferredContentSize = size
        @unknown default:
            preferredContentSize = maxSize
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
        dateLabel.isHidden = false
        removeTimeline()
        if ticket.departure.timeIntervalSinceNow > 60 * 60 * 2 {
            setupFullDate(with: ticket)
        } else if ticket.departure.timeIntervalSinceNow > 0 {
            setupDepartureDate(with: ticket)
        } else {
            dateLabel.isHidden = true
            setupTimeline(with: ticket)
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

    func removeTimeline() {
        stackView.arrangedSubviews
            .filter { $0 is TimelineView }
            .forEach {
                stackView.removeArrangedSubview($0)
                $0.removeFromSuperview() }
    }

    func setupTimeline(with ticket: Ticket) {
        let timeline = TimelineView()
        timeline.leftText = DateFormatters.shortTime.string(from: ticket.departure)
        timeline.rightText = DateFormatters.shortTime.string(from: ticket.arrival)
        let leftFormat = NSLocalizedString("time_left", comment: "")
        let leftTimeString = timeLeftFormatter.string(from: Date(), to: ticket.arrival) ?? ""
        timeline.centerText = String(format: leftFormat, leftTimeString)
        timeline.value = CGFloat(completePart(for: ticket))
        stackView.addArrangedSubview(timeline)
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

    func completePart(for ticket: Ticket) -> Double {
        let startTime = ticket.departure.timeIntervalSince1970
        let endTime = ticket.arrival.timeIntervalSince1970
        let currentTime = Date().timeIntervalSince1970
        let duration = endTime - startTime
        let complete = currentTime - startTime
        let value = complete / duration
        return min(1.0, max(0.0, value))
    }

    
}
