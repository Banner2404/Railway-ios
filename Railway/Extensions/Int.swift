//
//  Int.swift
//  Railway
//
//  Created by Евгений Соболь on 6/25/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation

extension Int {
    
    var string: String {
        switch self {
        case 1:
            return "Первое"
        case 2:
            return "Второе"
        case 3:
            return "Третье"
        case 4:
            return "Четвертое"
        case 5:
            return "Пятое"
        case 6:
            return "Шестое"
        case 7:
            return "Седьмое"
        case 8:
            return "Восьмое"
        case 9:
            return "Девятое"
        default:
            assertionFailure("Not supported")
            return ""
        }
    }
}
