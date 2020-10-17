//
//  WidgetRefreshManager.swift
//  Railway
//
//  Created by Евгений Соболь on 10/17/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import Foundation
import RxSwift
import WidgetKit

class WidgetRefreshManager {

    private let database: DatabaseManager
    private let disposeBag = DisposeBag()
    
    init(database: DatabaseManager) {
        self.database = database

        database.tickets
            .subscribe(onNext: { _ in
                self.refreshWidgets()
            })
            .disposed(by: disposeBag)
    }

    private func refreshWidgets() {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
