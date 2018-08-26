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
            return NSLocalizedString("Первое", comment: "")
        case 2:
            return NSLocalizedString("Второе", comment: "")
        case 3:
            return NSLocalizedString("Третье", comment: "")
        case 4:
            return NSLocalizedString("Четвертое", comment: "")
        case 5:
            return NSLocalizedString("Пятое", comment: "")
        case 6:
            return NSLocalizedString("Шестое", comment: "")
        case 7:
            return NSLocalizedString("Седьмое", comment: "")
        case 8:
            return NSLocalizedString("Восьмое", comment: "")
        case 9:
            return NSLocalizedString("Девятое", comment: "")
        default:
            assertionFailure("Not supported")
            return ""
        }
    }
}
