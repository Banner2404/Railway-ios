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
            return "Во время отправления"
        case .fiveMinutes:
            return "За 5 минут"
        case .tenMinutes:
            return "За 10 минут"
        case .fifteenMinutes:
            return "За 15 минут"
        case .halfHour:
            return "За 30 минут"
        case .oneHour:
            return "За 1 час"
        case .twoHours:
            return "За 2 часа"
        default:
            return ""
        }
    }
    
    var included: [NotificationAlert] {
        return NotificationAlert.all.filter { self.contains($0) }
    }
    
    var excluded: [NotificationAlert] {
        return NotificationAlert.all.filter { !self.contains($0) }
    }
}
