//
//  AddTicketViewModel.swift
//  Railway
//
//  Created by Евгений Соболь on 5/28/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AddTicketViewModel {
    
    let sourceName = BehaviorRelay<String>(value: "")
    let destinationName = BehaviorRelay<String>(value: "")
    let departureDate = BehaviorRelay<Date>(value: Date().nextHour)
    let arrivalDate = BehaviorRelay<Date>(value: Date().nextHour.addingTimeInterval(60 * 60))
    let notes = BehaviorRelay<String>(value: "")
    let places = BehaviorRelay<[AddPlaceViewModel]>(value: [AddPlaceViewModel(place: nil)])
    let bag = DisposeBag()
    let isValid = BehaviorRelay<Bool>(value: true)
    let isValidArrival: Observable<Bool>
    let addedTicket = PublishSubject<Ticket>()
    private let currentTicket: Ticket?
    
    init(currentTicket: Ticket?) {
        self.currentTicket = currentTicket
        isValidArrival = Observable.combineLatest(departureDate, arrivalDate)
            .map { $0 < $1 }
            .share()
        setupDefaultInfo()

        let sourceNameValid = sourceName
            .map { !$0.isEmpty }
            .share()
        let destinationNameValid = destinationName
            .map { !$0.isEmpty }
            .share()
        let placesValid = places.asObservable()
            .flatMapLatest { item -> Observable<Bool> in
                if item.isEmpty { return Observable.just(false) }
                return Observable.combineLatest(item.map { $0.isValid }).map { values in
                    values.reduce(true, { $0 && $1 })
                }
            }
            .share()
        
        
        Observable.combineLatest(sourceNameValid, destinationNameValid, placesValid, isValidArrival)
            .map { $0 && $1 && $2 && $3 }
            .bind(to: isValid)
            .disposed(by: bag)
        
    }
    
    func save() {
        let ticket = createTicket()
        addedTicket.onNext(ticket)
        addedTicket.onCompleted()
    }
    
    func setupDefaultInfo() {
        guard let currentTicket = currentTicket else { return }
        sourceName.accept(currentTicket.sourceStation.name)
        destinationName.accept(currentTicket.destinationStation.name)
        departureDate.accept(currentTicket.departure)
        arrivalDate.accept(currentTicket.arrival)
        places.accept(currentTicket.places.map { AddPlaceViewModel(place: $0) })
        notes.accept(currentTicket.notes)
    }
    
    private func createTicket() -> Ticket {
        let source = Station(name: sourceName.value)
        let destination = Station(name: destinationName.value)
        let places = self.places.value.map { $0.createPlace() }
        
        var ticket = Ticket(sourceStation: source,
               destinationStation: destination,
               departure: departureDate.value,
               arrival: arrivalDate.value,
               notes: notes.value,
               places: places)
        if let current = currentTicket {
            ticket.id = current.id
        }
        return ticket
    }
}
