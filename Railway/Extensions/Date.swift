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
}
