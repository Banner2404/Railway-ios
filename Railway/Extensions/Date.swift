//
//  Date.swift
//  Railway
//
//  Created by Евгений Соболь on 6/3/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation

extension Date {
    
    var year: String {
        return DateFormatters.year.string(from: self)
    }

    var minuteStart: Date {
        let calendar = Calendar.current
        guard var startDate = calendar.date(bySetting: .second, value: 0, of: self) else {
            fatalError("Unable to get minute start")
        }
        if startDate > self {
            startDate = startDate.addingTimeInterval(-60)
        }
        return startDate
    }
    
    var minuteEnd: Date {
        return minuteStart.addingTimeInterval(60 - 1)
    }
}
