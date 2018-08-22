//
//  TicketDetailsViewModel.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TicketDetailsViewModel {
    
    let fromText = BehaviorRelay<String>(value: "")
    let toText = BehaviorRelay<String>(value: "")
    let stationsText = BehaviorRelay<String>(value: "")
    let departureTimeText = BehaviorRelay<String>(value: "")
    let arrivalTimeText = BehaviorRelay<String>(value: "")
    let dateText = BehaviorRelay<String>(value: "")
    let notes = BehaviorRelay<String>(value: "")
    let places = BehaviorRelay<[PlaceViewModel]>(value: [])
    var deleteObservable: Observable<Ticket> {
        return deleteSubject.asObservable()
    }
    
    var editObservable: Observable<Ticket> {
        return editSubject.asObservable()
    }
    
    var editViewModel = PublishSubject<AddTicketViewModel>()
    var collapsedTicketViewModel: BehaviorRelay<TicketViewModel>
    var shareMessage: String {
        return
            "Поезд \(fromText.value) - \(toText.value)\n" +
            "\(dateText.value)\n" +
            "\(departureTimeText.value)-\(arrivalTimeText.value)"
    }
    
    private(set) var ticket: Ticket
    private let deleteSubject = PublishSubject<Ticket>()
    private let editSubject = PublishSubject<Ticket>()

    init(_ ticket: Ticket) {
        self.ticket = ticket
        collapsedTicketViewModel = BehaviorRelay(value: TicketViewModel(ticket))
        set(ticket)
    }
    
    func set(_ ticket: Ticket) {
        self.ticket = ticket
        stationsText.accept("\(ticket.sourceStation.name) - \(ticket.destinationStation.name)")
        fromText.accept(ticket.sourceStation.name)
        toText.accept(ticket.destinationStation.name)
        departureTimeText.accept(DateFormatters.shortTime.string(from: ticket.departure))
        arrivalTimeText.accept(DateFormatters.shortTime.string(from: ticket.arrival))
        dateText.accept(DateFormatters.longDate.string(from: ticket.departure))
        notes.accept(ticket.notes)
        places.accept(ticket.places.map { PlaceViewModel($0) })
        collapsedTicketViewModel.accept(TicketViewModel(ticket))
    }
    
    func delete() {
        deleteSubject.onNext(ticket)
    }
    
    func edit() {
        editSubject.onNext(ticket)
    }
}
