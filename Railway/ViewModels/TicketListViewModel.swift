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
        return ticketViewModelRelay.asObservable()
    }
    
    private var ticketViewModelRelay = BehaviorRelay<[TicketViewModel]>(value: [])
    private var ticketsRelay = BehaviorRelay<[Ticket]>(value: [])
    private let databaseManager: DatabaseManager
    private let disposeBag = DisposeBag()
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
//        let minsk = Station(name: "Minsk test")
//        let brest = Station(name: "Brest")
//        let gomel = Station(name: "Gomel")
//        let place1 = Place(carriage: 10, seat: "10a")
//        let place2 = Place(carriage: 10, seat: "11a")
//        let place3 = Place(carriage: 9, seat: "10")
//
//        let ticketOne = Ticket(sourceStation: minsk, destinationStation: brest, departure: Date(), arrival: Date(), places: [place1, place2, place3])
        //let ticketTwo = Ticket(sourceStation: minsk, destinationStation: gomel, departure: Date(), arrival: Date(), places: [])
        //databaseManager.create(ticketOne)
        //databaseManager.create(ticketTwo)
        let tickets = databaseManager.loadTickets()
        ticketsRelay
            .map { $0.map { TicketViewModel($0)} }
            .bind(to: ticketViewModelRelay)
            .disposed(by: disposeBag)
        ticketsRelay.accept(tickets)
    }
    
    func ticketViewModel(at index: Int) -> TicketDetailsViewModel {
        let ticket = ticketsRelay.value[index]
        return TicketDetailsViewModel(ticket)
    }
    
    func addViewModel() -> AddTicketViewModel {
        return AddTicketViewModel()
    }
}
