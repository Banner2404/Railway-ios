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
    
    var isEnabled = BehaviorRelay<Bool>(value: false)
    var alerts = BehaviorRelay<NotificationAlert>(value: [.fiveMinutes, .oneHour])
    
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
        loadSettings()
        database.tickets
            .subscribe(onNext: { _ in
                self.updateNotifications()
            })
            .disposed(by: disposeBag)
        
        isEnabled.asObservable()
            .subscribe(onNext: { _ in
                self.saveSettings()
                self.updateNotifications()
            })
            .disposed(by: disposeBag)
        
        alerts.asObservable()
            .subscribe(onNext: { _ in
                self.saveSettings()
                self.updateNotifications()
            })
            .disposed(by: disposeBag)
        
    }
    
    private func loadSettings() {
        if let (enabled, alerts) = database.getNotificationSettings() {
            self.isEnabled.accept(enabled)
            self.alerts.accept(alerts)
        } else {
            self.isEnabled.accept(false)
            self.alerts.accept([.fiveMinutes, .oneHour])
        }
       
    }
    
    private func saveSettings() {
        database.saveNotificationSettings(isEnabled: isEnabled.value, alerts: alerts.value)
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
    
    private func updateNotifications() {
        guard let tickets = try? database.tickets.value() else { return }
        setupNotifications(for: tickets)
    }
    
    private func setupNotifications(for tickets: [Ticket]) {
        resetNotifications()
        if !isEnabled.value { return }
        for ticket in tickets where ticket.departure > Date() {
            setupNotifications(for: ticket)
        }
    }
    
    private func setupNotifications(for ticket: Ticket) {
        for alert in alerts.value.included {
            setupNotifications(for: ticket, alert: alert)
        }
    }
    
    private func setupNotifications(for ticket: Ticket, alert: NotificationAlert) {
        let content = createNotificationContent(for: ticket, alert: alert)
        let trigger = createNotificationTrigger(for: ticket, alert: alert)
        let identifier = createNotificationIdentifier(for: ticket, alert: alert)
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(notificationRequest) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func createNotificationIdentifier(for ticket: Ticket, alert: NotificationAlert) -> String {
        return "\(ticket.id)-\(alert.rawValue)"
    }
    
    private func createNotificationContent(for ticket: Ticket, alert: NotificationAlert) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        let train = NSLocalizedString("Поезд", comment: "")
        content.title = "\(train) \(ticket.sourceStation.name) - \(ticket.destinationStation.name)"
        content.body = "\(timeString(for: alert))\(seatString(for: ticket))"
        return content
    }
    
    private func timeString(for alert: NotificationAlert) -> String {
        if alert == .atEventTime { return NSLocalizedString("Сейчас", comment: "") }
        let inPrefix = NSLocalizedString("Через", comment: "")
        return "\(inPrefix) \(dateComponentsFormatter.string(from: alert.timeInterval ?? 0.0) ?? "")"
    }
    
    private func seatString(for ticket: Ticket) -> String {
        guard ticket.places.count == 1 else { return "" }
        let place = ticket.places[0]
        let carriage = NSLocalizedString("вагон", comment: "")
        let seat = NSLocalizedString("место", comment: "")
        return "\n\(place.carriage) \(carriage) \(place.seat) \(seat)"
    }
    
    private func createNotificationTrigger(for ticket: Ticket, alert: NotificationAlert) -> UNNotificationTrigger {
        guard let timeInterval = alert.timeInterval else { fatalError("incorrect notification alert") }
        let components = getNotificationComponents(from: ticket.departure.addingTimeInterval(-timeInterval))
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }
    
    private func getNotificationComponents(from date: Date) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
    }
}
