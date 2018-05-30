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
    let carriage = BehaviorRelay<String>(value: "")
    let seat = BehaviorRelay<String>(value: "")
}
