//
//  AddPlaceViewModel.swift
//  Railway
//
//  Created by Евгений Соболь on 5/30/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AddPlaceViewModel {
    
    let carriage = BehaviorRelay<Int>(value: 0)
    let seat = BehaviorRelay<String>(value: "")
    let isValid = BehaviorRelay<Bool>(value: true)
    let disposeBag = DisposeBag()
    
    init(place: Place?) {
        let carriageValid = carriage
            .map { $0 > 0 }
            .share()
        let seatValid = seat
            .map { !$0.isEmpty }
            .share()
        
        Observable.combineLatest(carriageValid, seatValid)
            .map { $0 && $1 }
            .bind(to: isValid)
            .disposed(by: disposeBag)
        setupDefailtInfo(place: place)
    }
    
    func setupDefailtInfo(place: Place?) {
        guard let place = place else { return }
        carriage.accept(place.carriage)
        seat.accept(place.seat)
    }
    
    func createPlace() -> Place {
        return Place(carriage: carriage.value,
                     seat: seat.value)
    }
}
