//
//  DateFormatters.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation

class DateFormatters {
    
    static var longDateAndTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM, HH:mm"
        return dateFormatter
    }()
    
    static var longDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM"
        return dateFormatter
    }()
    
    static var longDateShortMonth: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMM"
        return dateFormatter
    }()
    
    static var shortDateAndTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, H:mm"
        return dateFormatter
    }()
    
    static var emailDateAndTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy dd.MM HH:mm"
        return dateFormatter
    }()
    
    static var shortTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    static var year: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter
    }()
    
    static var gmailQuery: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter
    }()
}
