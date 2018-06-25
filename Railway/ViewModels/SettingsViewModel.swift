//
//  SettingsViewModel.swift
//  Railway
//
//  Created by Евгений Соболь on 6/9/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsViewModel {

    var isGmailConnected: Observable<Bool> {
        return mailSyncronizer.isAuthenticated
    }
    
    private let mailSyncronizer: MailSyncronizer
    private let notificationManager: NotificationManager
    
    init(mailSyncronizer: MailSyncronizer, notificationManager: NotificationManager) {
        self.mailSyncronizer = mailSyncronizer
        self.notificationManager = notificationManager
    }
    
    func signInMail(on viewController: UIViewController) -> Single<Void> {
        return mailSyncronizer.requestSignIn(on: viewController)
    }
    
    func signOutMail() {
        mailSyncronizer.signOut()
    }
    
    func syncTickets() {
        mailSyncronizer.sync()
    }
    
    func getNotificationsViewModel() -> NotificationsViewModel {
        return NotificationsViewModel(notificationManager: notificationManager)
    }
}
