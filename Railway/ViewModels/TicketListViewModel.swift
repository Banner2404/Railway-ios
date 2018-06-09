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
    
    var pastTickets: Observable<[TicketViewModel]> {
        return ticketsRelay.map { $0
            .sorted { $0.departure < $1.departure }
            .filter { $0.departure <= Date() }
            .map { TicketViewModel($0) }
        }
    }
    
    var futureTickets: Observable<[TicketViewModel]> {
        return ticketsRelay.map { $0
            .sorted { $0.departure < $1.departure }
            .filter { $0.departure > Date() }
            .map { TicketViewModel($0) }
        }
    }
    
    private var ticketsRelay = BehaviorRelay<[Ticket]>(value: [])
    private let databaseManager: DatabaseManager
    private let mailSyncronizer: MailSyncronizer
    private let disposeBag = DisposeBag()
    
    init(databaseManager: DatabaseManager, mailSyncronizer: MailSyncronizer) {
        self.databaseManager = databaseManager
        self.mailSyncronizer = mailSyncronizer
        let tickets = databaseManager.loadTickets()
        ticketsRelay.accept(tickets)
    }
    
    func ticketViewModel(at index: Int) -> TicketDetailsViewModel {
        let ticket = ticketsRelay.value[index]
        return TicketDetailsViewModel(ticket)
    }
    
    func addViewModel() -> AddTicketViewModel {
        let viewModel = AddTicketViewModel(databaseManager: databaseManager)
        viewModel.addedTicket.subscribe(onNext: { ticket in
            self.ticketsRelay.accept(self.ticketsRelay.value + [ticket])
        }).disposed(by: disposeBag)
        return viewModel
    }
    
    func settingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(mailSyncronizer: mailSyncronizer)
    }
}
