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
    let departureDate = BehaviorRelay<Date>(value: Date())
    let arrivalDate = BehaviorRelay<Date>(value: Date())
    let places = Variable<[AddPlaceViewModel]>([AddPlaceViewModel()])
    let bag = DisposeBag()
    let isValid = BehaviorRelay<Bool>(value: true)
    
    init() {
        let sourceNameValid = sourceName
            .map { !$0.isEmpty }
            .share()
        let destinationNameValid = destinationName
            .map { !$0.isEmpty }
            .share()
        let placesValid = places.asObservable()
            .flatMapLatest { item -> Observable<Bool> in
                if item.isEmpty { return Observable.just(false) }
                return Observable.combineLatest(item.map { $0.isValid }).debug().map { values in
                    values.reduce(true, { $0 && $1 })
                }
            }
            .share()
        
        
        Observable.combineLatest(sourceNameValid, destinationNameValid, placesValid)
            .map { $0 && $1 && $2 }
            .bind(to: isValid)
            .disposed(by: bag)
        
    }
}
