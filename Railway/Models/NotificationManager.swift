//
//  NotificationManager.swift
//  Railway
//
//  Created by Евгений Соболь on 6/17/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UserNotifications

class NotificationManager {
    
    var isEnabled = Variable<Bool>(false)
    var alerts = Variable<NotificationAlert>([.fiveMinutes, .oneHour])
    
    private let timeInterval: TimeInterval = 60 * 60
    private let database: DatabaseManager
    private let disposeBag = DisposeBag()
    private let notificationCenter = UNUserNotificationCenter.current()
    private lazy var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = false
        return formatter
    }()
    
    init(database: DatabaseManager) {
        self.database = database
        checkAuthorization()
        database.tickets
            .subscribe(onNext: { tickets in
                self.setupNotifications(for: tickets)
            })
            .disposed(by: disposeBag)
    }
    
    private func checkAuthorization() {
        notificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                self.requestAuthorization()
            }
        }
    }
    
    private func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            print("Granted:", granted)
        }
    }
    
    private func resetNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    private func setupNotifications(for tickets: [Ticket]) {
        resetNotifications()
        for ticket in tickets where ticket.departure > Date() {
            setupNotifications(for: ticket)
        }
    }
    
    private func setupNotifications(for ticket: Ticket) {
        let content = createNotificationContent(for: ticket)
        let trigger = createNotificationTrigger(for: ticket)
        let notificationRequest = UNNotificationRequest(identifier: ticket.id, content: content, trigger: trigger)
        notificationCenter.add(notificationRequest) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func createNotificationContent(for ticket: Ticket) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Поезд \(ticket.sourceStation.name) - \(ticket.destinationStation.name)"
        content.body = "Через \(dateComponentsFormatter.string(from: timeInterval) ?? "")\(seatString(for: ticket))"
        return content
    }
    
    private func seatString(for ticket: Ticket) -> String {
        guard ticket.places.count == 1 else { return "" }
        let place = ticket.places[0]
        return "\n\(place.carriage) вагон \(place.seat) место"
    }
    
    private func createNotificationTrigger(for ticket: Ticket) -> UNNotificationTrigger {
        let components = getNotificationComponents(from: ticket.departure.addingTimeInterval(-timeInterval))
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }
    
    private func getNotificationComponents(from date: Date) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
    }
}
