//
//  MessageProcessor.swift
//  Railway
//
//  Created by Евгений Соболь on 6/3/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import PDFKit

class MessageProcessor {
    
    static func process(messageData: String) -> [Ticket] {
        let fixedString = messageData.fixed
        guard let data = Data(base64Encoded: fixedString),
            let document = PDFDocument(data: data) else { return [] }
        return tickets(from: document)
    }
    
    private static func tickets(from document: PDFDocument) -> [Ticket] {
        var result = [Ticket]()
        for index in 0..<document.pageCount {
            guard let page = document.page(at: index),
                let ticket = ticket(from: page) else { continue }
            result.append(ticket)
        }
        return result
    }
    
    private static func ticket(from page: PDFPage) -> Ticket? {
        let strings = page.string?.components(separatedBy: "\n") ?? []
        if let ticket = ticket(from: strings, parser: legacyTicketParser(from:offset:)) {
            return ticket
        } else {
            return ticket(from: strings, parser: newTicketParser(from:offset:))
        }
    }
    
    private static func ticket(from strings: [String], parser: ([String], Int) -> Ticket?) -> Ticket? {
        guard strings.count > 10 else { return nil }
        if strings[5].contains("Контрольный номер") {
            return parser(strings, 3)
        } else if strings[5].contains("Номер заказа") {
            return parser(strings, 2)
        } else {
            return parser(strings, 0)
        }
    }

    private static func legacyTicketParser(from strings: [String], offset: Int) -> Ticket? {
        return ticket(from: strings, offset: offset, yearOffset: 0)
    }

    private static func newTicketParser(from strings: [String], offset: Int) -> Ticket? {
        return ticket(from: strings, offset: offset + 1, yearOffset: -1)
    }

    private static func ticket(from strings: [String], offset: Int, yearOffset: Int) -> Ticket? {
        guard strings.count > 23 + offset else { return nil }
        let departureYearString = String(strings[5 + offset + yearOffset])
        let departureYear = year(fromString: departureYearString)
        let departureDay = String(strings[14 + offset])
        let departureTime = String(strings[15 + offset])
        guard let departure = date(fromDateString: departureDay, timeString: departureTime, year: departureYear) else { return nil }

        let arrivalDay = String(strings[18 + offset])
        let arrivalTime = String(strings[19 + offset])
        guard let arrival = date(fromDateString: arrivalDay, timeString: arrivalTime, year: departureYear) else { return nil }
        let route = strings[16 + offset].split(separator: "→")
        guard let from = route.first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).capitalized,
            let to = route.last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).capitalized else { return nil }

        let source = Station(name: from)
        let destination = Station(name: to)

        let placeString = strings[23 + offset]
        guard let place = self.place(from: String(placeString)) else { return nil }

        return Ticket(sourceStation: source, destinationStation: destination, departure: departure, arrival: arrival, notes: "", places: [place])
    }

    private static func year(fromString string: String) -> String? {
        let yearRegex = "\\d{4}"
        if let yearRange = string.range(of: yearRegex, options: .regularExpression), let year = Int(string[yearRange]) {
            return String(year)
        }
        return nil
    }
    
    private static func date(fromDateString dateString: String, timeString: String, year: String?) -> Date? {
        let year = year ?? Date().year
        let fullDateString = "\(year) \(dateString.trimmed) \(timeString.trimmed)"
        return DateFormatters.emailDateAndTime.date(from: fullDateString)
    }
    
    private static func place(from string: String) -> Place? {
        let components = string.trimmed.components(separatedBy: " ")
        if components.count < 8 { return nil }
        guard let carriage = Int(components[3]) else { return nil}
        let seat = components[7]
        let cleanSeat = String(seat.drop { $0 == "0" })
        return Place(carriage: carriage, seat: cleanSeat)
    }
}

//MARK: - Private
fileprivate extension String {
    
    var fixed: String {
        return self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
    }
    
    var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
