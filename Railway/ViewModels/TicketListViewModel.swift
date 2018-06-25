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
    
    var isSyncronizing: Observable<Bool> {
        return mailSyncronizer.isSyncronizing
    }
    
    private let allTicketsViewModelsRelay = BehaviorRelay<[TicketViewModel]>(value: [])
    private let allTicketsRelay = BehaviorRelay<[Ticket]>(value: [])
    private let databaseManager: DatabaseManager
    private let mailSyncronizer: MailSyncronizer
    private let notificationManager: NotificationManager
    private let disposeBag = DisposeBag()
    
    init(databaseManager: DatabaseManager, mailSyncronizer: MailSyncronizer, notificationManager: NotificationManager) {
        self.databaseManager = databaseManager
        self.mailSyncronizer = mailSyncronizer
        self.notificationManager = notificationManager
        
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
        let viewModel = TicketDetailsViewModel(ticket)
        viewModel.deleteObservable
            .subscribe(onNext: { _ in
                self.databaseManager.delete(ticket)
            })
            .disposed(by: disposeBag)
        
        viewModel.editObservable
            .subscribe(onNext: { _ in
                viewModel.editViewModel.onNext(self.editViewModel(ticket, detailsViewModel: viewModel))
            })
            .disposed(by: disposeBag)
        return viewModel
    }
    
    func addViewModel() -> AddTicketViewModel {
        let viewModel = AddTicketViewModel(currentTicket: nil)
        viewModel.addedTicket
            .subscribe(onNext: { ticket in
                self.databaseManager.add(ticket)
            })
            .disposed(by: disposeBag)
        return viewModel
    }
    
    func editViewModel(_ ticket: Ticket, detailsViewModel: TicketDetailsViewModel) -> AddTicketViewModel {
        let viewModel = AddTicketViewModel(currentTicket: ticket)
        viewModel.addedTicket
            .subscribe(onNext: { ticket in
                self.databaseManager.update(ticket)
                detailsViewModel.set(ticket)
            })
            .disposed(by: disposeBag)
        
        
        return viewModel
    }
    
    func settingsViewModel() -> SettingsViewModel {
        return SettingsViewModel(mailSyncronizer: mailSyncronizer, notificationManager: notificationManager)
    }
}
