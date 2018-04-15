//
//  TicketListViewModel.swift
//  Railway
//
//  Created by Евгений Соболь on 4/3/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TicketListViewModel {
    
    var tickets: Observable<[TicketViewModel]> {
        return ticketsRelay.asObservable()
    }
    private var ticketsRelay = BehaviorRelay<[TicketViewModel]>(value: [])
    private let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
//        let minsk = Station(name: "Minsk")
//        let brest = Station(name: "Brest")
//        let gomel = Station(name: "Gomel")
//        let ticketOne = Ticket(sourceStation: minsk, destinationStation: brest, departure: Date(), arrival: Date(), places: [])
//        let ticketTwo = Ticket(sourceStation: minsk, destinationStation: gomel, departure: Date(), arrival: Date(), places: [])
//        databaseManager.create(ticketOne)
//        databaseManager.create(ticketTwo)
        let tickets = databaseManager.loadTickets()
        
        ticketsRelay.accept(tickets.map { TicketViewModel($0) })
    }
}
