//
//  NotificationAlert.swift
//  Railway
//
//  Created by Евгений Соболь on 6/25/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation

struct NotificationAlert: OptionSet  {
    
    let rawValue: Int
    static let atEventTime = NotificationAlert(rawValue: 1 << 0)
    static let fiveMinutes = NotificationAlert(rawValue: 1 << 1)
    static let tenMinutes = NotificationAlert(rawValue: 1 << 2)
    static let fifteenMinutes = NotificationAlert(rawValue: 1 << 3)
    static let halfHour = NotificationAlert(rawValue: 1 << 4)
    static let oneHour = NotificationAlert(rawValue: 1 << 5)
    static let twoHours = NotificationAlert(rawValue: 1 << 6)
    
    static let all: [NotificationAlert] = [.atEventTime, .fiveMinutes, .tenMinutes, .fifteenMinutes, .halfHour, .oneHour, .twoHours]
    var string: String {
        switch self {
        case .atEventTime:
            return NSLocalizedString("Во время отправления", comment: "")
        case .fiveMinutes:
            return NSLocalizedString("За 5 минут", comment: "")
        case .tenMinutes:
            return NSLocalizedString("За 10 минут", comment: "")
        case .fifteenMinutes:
            return NSLocalizedString("За 15 минут", comment: "")
        case .halfHour:
            return NSLocalizedString("За 30 минут", comment: "")
        case .oneHour:
            return NSLocalizedString("За 1 час", comment: "")
        case .twoHours:
            return NSLocalizedString("За 2 часа", comment: "")
        default:
            return ""
        }
    }
    
    var timeInterval: TimeInterval? {
        switch self {
        case .atEventTime:
            return 0.0
        case .fiveMinutes:
            return 5 * 60.0
        case .tenMinutes:
            return 10 * 60.0
        case .fifteenMinutes:
            return 15 * 60.0
        case .halfHour:
            return 30 * 60.0
        case .oneHour:
            return 60 * 60.0
        case .twoHours:
            return 2 * 60 * 60.0
        default:
            return nil
        }
    }
    
    var included: [NotificationAlert] {
        return NotificationAlert.all.reversed().filter { self.contains($0) }
    }
    
    var excluded: [NotificationAlert] {
        return NotificationAlert.all.reversed().filter { !self.contains($0) }
    }
}
