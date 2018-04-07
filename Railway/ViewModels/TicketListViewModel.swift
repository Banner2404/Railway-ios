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
    
    init() {
        let minsk = Station(name: "Minsk")
        let brest = Station(name: "Brest")
        let gomel = Station(name: "Gomel")
        let tickets = [
            Ticket(sourceStation: minsk, destinationStation: brest, departure: Date(), arrival: Date(), places: []),
            Ticket(sourceStation: brest, destinationStation: minsk, departure: Date(), arrival: Date(), places: []),
            Ticket(sourceStation: gomel, destinationStation: minsk, departure: Date(), arrival: Date(), places: [])]
        
        ticketsRelay.accept(tickets.map { TicketViewModel($0) })
    }
}
