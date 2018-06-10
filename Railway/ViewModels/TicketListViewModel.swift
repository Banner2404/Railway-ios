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
    
    var allTickets: Observable<[TicketViewModel]> {
        return allTicketsViewModelsRelay.asObservable()
    }
    
    private let allTicketsViewModelsRelay = BehaviorRelay<[TicketViewModel]>(value: [])
    private let allTicketsRelay = BehaviorRelay<[Ticket]>(value: [])
    private let databaseManager: DatabaseManager
    private let mailSyncronizer: MailSyncronizer
    private let disposeBag = DisposeBag()
    
    init(databaseManager: DatabaseManager, mailSyncronizer: MailSyncronizer) {
        self.databaseManager = databaseManager
        self.mailSyncronizer = mailSyncronizer
        
        allTicketsRelay
            .map { tickets in
                tickets.map { ticket in
                    TicketViewModel(ticket)
                }
            }
            .bind(to: allTicketsViewModelsRelay)
            .disposed(by: disposeBag)

        databaseManager.tickets.map { tickets in
                tickets.sorted { $0.departure < $1.departure }
            }
            .bind(to: allTicketsRelay)
            .disposed(by: disposeBag)
    }
    
    func detailedTicketViewModel(for viewModel: TicketViewModel) -> TicketDetailsViewModel? {
        guard let index = allTicketsViewModelsRelay.value.index(where: { $0 === viewModel }) else { return nil }
        let ticket = allTicketsRelay.value[index]
        return TicketDetailsViewModel(ticket)
    }
    
    func addViewModel() -> AddTicketViewModel {
        return AddTicketViewModel(databaseManager: databaseManager)
    }
    
    func settingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(mailSyncronizer: mailSyncronizer)
    }
}
