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
    
    private let database: DatabaseManager
    private let disposeBag = DisposeBag()
    private let notificationCenter = UNUserNotificationCenter.current()
    private lazy var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
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
        for ticket in tickets {
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
        content.title = "Поезд"
        content.body = "Поезд по маршруту \(ticket.sourceStation.name) - \(ticket.destinationStation.name) отправляется через \(dateComponentsFormatter.string(from: Date(), to: ticket.departure) ?? "")"
        return content
    }
    
    private func createNotificationTrigger(for ticket: Ticket) -> UNNotificationTrigger {
        let components = getNotificationComponents(from: ticket.departure.addingTimeInterval(-60 * 2))
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }
    
    private func getNotificationComponents(from date: Date) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
    }
}
