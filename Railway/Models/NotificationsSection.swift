//
//  NotificationsSection.swift
//  Railway
//
//  Created by Евгений Соболь on 6/24/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import RxDataSources

struct NotificationsSection {
    var items: [NotificationsSection.CellType]
    
    init(items: [NotificationsSection.CellType]) {
        self.items = items
    }
    
    enum CellType {
        case toggle
        case record(alert: NotificationAlert)
        
        var cellIdentifier: String {
            switch self {
            case .toggle:
                return "NotificationsToggleTableViewCell"
            case .record:
                return "NotificationRecordTableViewCell"
            }
        }
    }
}

extension NotificationsSection: SectionModelType {
    
    typealias Item = CellType
    
    init(original: NotificationsSection, items: [NotificationsSection.CellType]) {
        self = original
        self.items = items
    }
    
    
}
