//
//  PhoneConnectivityManager.swift
//  Railway Watch Extension
//
//  Created by Евгений Соболь on 8/22/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit

protocol PhoneConnectivityManagerDelegate: class {
    func phoneConnectivityManager(_ manager: PhoneConnectivityManager, didRecieve tickets: [Ticket])
}

class PhoneConnectivityManager: NSObject {

    weak var delegate: PhoneConnectivityManagerDelegate?
    
    private var session: WCSession?
    
    func activate() {
        setupSession()
    }
    
    func requestInitialData() {
        session?.sendMessage(["type": "initialRequest"], replyHandler: { (data) in
            let tickets = self.tickets(from: data)
            self.delegate?.phoneConnectivityManager(self, didRecieve: tickets)
        }, errorHandler: nil)
    }
    
    private func setupSession() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        self.session = session
    }
    
    private func tickets(from context: [String: Any]) -> [Ticket] {
        guard let data = context["tickets"] as? [Data] else { return [] }
        let decoder = PropertyListDecoder()
        guard let tickets = try? data.map({ try decoder.decode(Ticket.self, from: $0)}) else { return [] }
        return tickets
    }
}

//MARK: - WCSessionDelegate
extension PhoneConnectivityManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activated")
        if let error = error {
            print("Activation error: \(error)")
        }
        requestInitialData()
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        let tickets = self.tickets(from: applicationContext)
        delegate?.phoneConnectivityManager(self, didRecieve: tickets)
    }
}
