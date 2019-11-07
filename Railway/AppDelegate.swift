//
//  AppDelegate.swift
//  Railway
//
//  Created by Евгений Соболь on 4/3/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import GoogleSignIn
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var watchConnectivityManager: WatchConnectivityManager!
    var mailSyncronizer: MailSyncronizer!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(Locale.current)
        Fabric.with([Crashlytics.self])
        GIDSignIn.sharedInstance().clientID = "828532157765-6v55upkt90dsau7mh3m8qvi13bbiveq4.apps.googleusercontent.com"
        let database = DefaultDatabaseManager()
        database.loadTickets()
        watchConnectivityManager = WatchConnectivityManager(database: database)
        let notification = NotificationManager(database: database)
        mailSyncronizer = GmailSyncronizer(databaseManager: database)
        let viewModel = TicketListViewModel(databaseManager: database, mailSyncronizer: mailSyncronizer, notificationManager: notification)
        let rootController = TicketListViewController.loadFromStoryboard(viewModel: viewModel)
        let navigationController = NavigationController(rootViewController: rootController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        application.setMinimumBackgroundFetchInterval(30 * 60)
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        mailSyncronizer.sync()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completionHandler(.noData)
        }
    }
    
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
}

