//
//  NotificationsViewModel.swift
//  Railway
//
//  Created by Евгений Соболь on 6/24/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NotificationsViewModel {
    
    var isEnabled: Variable<Bool> {
        return notificationManager.isEnabled
    }
    
    var alerts: Variable<NotificationAlert> {
        return notificationManager.alerts
    }
    
    private let notificationManager: NotificationManager
    
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }
}
