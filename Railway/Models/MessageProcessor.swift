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
        let strings = page.string?.split(separator: "\n") ?? []
        let departureDay = String(strings[14])
        let departureTime = String(strings[15])
        guard let departure = date(fromDateString: departureDay, timeString: departureTime) else { return nil }
        
        let arrivalDay = String(strings[18])
        let arrivalTime = String(strings[19])
        guard let arrival = date(fromDateString: arrivalDay, timeString: arrivalTime) else { return nil }

        let route = strings[16].split(separator: "→")
        guard let from = route.first?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).capitalized,
            let to = route.last?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).capitalized else { return nil }
        
        let source = Station(name: from)
        let destination = Station(name: to)
        
        let placeString = strings[23]
        guard let place = self.place(from: String(placeString)) else { return nil }

        return Ticket(sourceStation: source, destinationStation: destination, departure: departure, arrival: arrival, places: [place])
    }
    
    private static func date(fromDateString dateString: String, timeString: String) -> Date? {
        let fullDateString = "\(Date().year) \(dateString.trimmed) \(timeString.trimmed)"
        return DateFormatters.emailDateAndTime.date(from: fullDateString)
    }
    
    private static func place(from string: String) -> Place? {
        let components = string.trimmed.components(separatedBy: " ")
        if components.count < 8 { return nil }
        guard let carriage = Int(components[3]) else { return nil}
        let seat = components[7]
        return Place(carriage: carriage, seat: seat)
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
