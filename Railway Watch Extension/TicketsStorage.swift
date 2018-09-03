//
//  TicketsStorage.swift
//  Railway Watch Extension
//
//  Created by Евгений Соболь on 8/26/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation

class TicketsStorage {
    
    var futureTickets: [Ticket] {
        return tickets.filter { $0.arrival > Date() }
    }
    private var tickets: [Ticket] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .ticketsDidUpdate, object: nil)
            }
        }
    }
    private let connectivityManager: PhoneConnectivityManager
    static let shared = TicketsStorage()
    
    private init() {
        connectivityManager = PhoneConnectivityManager()
        connectivityManager.delegate = self
    }
    
    func activate() {
        connectivityManager.activate()
    }
    
    func reloadData() {
        connectivityManager.requestInitialData()
    }
}

//MARK: - PhoneConnectivityManagerDelegate
extension TicketsStorage: PhoneConnectivityManagerDelegate {
    
    func phoneConnectivityManager(_ manager: PhoneConnectivityManager, didRecieve tickets: [Ticket]) {
        self.tickets = tickets
        
    }
}

extension Notification.Name {
    
    static let ticketsDidUpdate = Notification.Name(rawValue: "ticketsDidUpdate")
}
