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
    
    private let mailSyncronizer: MailSyncronizer
    
    init(mailSyncronizer: MailSyncronizer) {
        self.mailSyncronizer = mailSyncronizer
    }
    
    func signInMail(on viewController: UIViewController) -> Single<Void> {
        return mailSyncronizer.requestSignIn(on: viewController)
    }
    
    func syncTickets() {
        mailSyncronizer.sync()
    }
}
