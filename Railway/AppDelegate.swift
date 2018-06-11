//
//  AppDelegate.swift
//  Railway
//
//  Created by Евгений Соболь on 4/3/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GIDSignIn.sharedInstance().clientID = "828532157765-6v55upkt90dsau7mh3m8qvi13bbiveq4.apps.googleusercontent.com"
        let database = DefaultDatabaseManager()
        let mail = GmailSyncronizer(databaseManager: database)
        let viewModel = TicketListViewModel(databaseManager: database, mailSyncronizer: mail)
        let rootController = TicketListViewController.loadFromStoryboard(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: rootController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
}

