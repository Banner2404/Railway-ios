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
    
    let stationsText = BehaviorRelay<String>(value: "")
    let departureTimeText = BehaviorRelay<String>(value: "")
    let arrivalTimeText = BehaviorRelay<String>(value: "")
    let dateText = BehaviorRelay<String>(value: "")
    let places = BehaviorRelay<[PlaceViewModel]>(value: [])
    var deleteObservable: Observable<Void> {
        return deleteSubject.asObservable()
    }
    
    var editObservable: Observable<Void> {
        return editSubject.asObservable()
    }
    
    var editViewModel = PublishSubject<AddTicketViewModel>()
    
    private let deleteSubject = PublishSubject<Void>()
    private let editSubject = PublishSubject<Void>()

    init(_ ticket: Ticket) {
        set(ticket)
    }
    
    func set(_ ticket: Ticket) {
        stationsText.accept("\(ticket.sourceStation.name) - \(ticket.destinationStation.name)")
        departureTimeText.accept(DateFormatters.shortTime.string(from: ticket.departure))
        arrivalTimeText.accept(DateFormatters.shortTime.string(from: ticket.arrival))
        dateText.accept(DateFormatters.longDate.string(from: ticket.departure))
        places.accept(ticket.places.map { PlaceViewModel($0) })
    }
    
    func delete() {
        deleteSubject.onNext(())
    }
    
    func edit() {
        editSubject.onNext(())
    }
}
