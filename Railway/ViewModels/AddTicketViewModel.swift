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
    let bag = DisposeBag()
    
    init() {
        sourceName.subscribe {
            print($0)
        }.disposed(by: bag)
        destinationName.subscribe {
            print($0)
        }.disposed(by: bag)
    }
}
