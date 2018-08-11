//
//  WatchConnectivityManager.swift
//  Railway
//
//  Created by Евгений Соболь on 8/11/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import WatchConnectivity
import RxSwift

class WatchConnectivityManager: NSObject {
    
    private let session = WCSession.default
    private let disposeBag = DisposeBag()
    private let database: DatabaseManager
    
    init(database: DatabaseManager) {
        self.database = database
        super.init()
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
        database.tickets
            .subscribe(onNext: { tickets in
                self.sync(tickets: tickets)
            })
            .disposed(by: disposeBag)
    }
    
    private func sendTickets() {
        guard let tickets = try? database.tickets.value() else { return }
        sync(tickets: tickets)
    }
    
    private func sync(tickets: [Ticket]) {
        guard session.isWatchAppInstalled else { return }
        let filtered = tickets
            .filter { $0.arrival > Date() }
            .sorted { $0.arrival < $1.arrival }
        let encoder = PropertyListEncoder()
        do {
            let data = try filtered.map { try encoder.encode($0) }
            let context = ["tickets": data]
            try session.updateApplicationContext(context)
        } catch {
            print(error)
        }
    }
}

//MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session deactivated")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Activation error: \(error)")
        } else if activationState == .activated {
            sendTickets()
        }
    }
    
}
