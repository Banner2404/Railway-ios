//
//  ComplicationsConroller.swift
//  Railway Watch Extension
//
//  Created by Евгений Соболь on 8/26/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import WatchKit

class ComplicationsController: NSObject, CLKComplicationDataSource {
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(ticketsDidUpdate), name: .ticketsDidUpdate, object: nil)
    }
    
    static func reloadComplications() {
        print("Reload complications")
        let server = CLKComplicationServer.sharedInstance()
        guard let complications = server.activeComplications else { return }
        complications.forEach {
            server.reloadTimeline(for: $0)
        }
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication,
                                          withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication,
                                 withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let ticket = TicketsStorage.shared.futureTickets.first
        if let template = createTemplate(for: complication, ticket: ticket) {
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        } else {
            handler(nil)
        }
        
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = createTemplate(for: complication, ticket: Ticket.fake)
        handler(template)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.hideOnLockScreen)
    }
    
    @objc
    private func ticketsDidUpdate() {
        ComplicationsController.reloadComplications()
    }
    
    private func createTemplate(for complication: CLKComplication, ticket: Ticket?) -> CLKComplicationTemplate? {
        switch complication.family {
        case .modularSmall:
            return CLKComplicationTemplateModularSmallColumnsText(ticket: ticket)
        case .modularLarge:
            return CLKComplicationTemplateModularLargeTable(ticket: ticket)
        case .utilitarianSmall:
            return CLKComplicationTemplateUtilitarianSmallFlat(ticket: ticket)
        case .utilitarianSmallFlat:
            return CLKComplicationTemplateUtilitarianSmallFlat(ticket: ticket)
        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(ticket: ticket)
        default:
            break
        }
        if #available(watchOSApplicationExtension 5.0, *) {
            switch complication.family {
            case .graphicCorner:
                if let ticket = ticket, ticket.departure < Date() {
                    return CLKComplicationTemplateGraphicCornerGaugeText(ticket: ticket)
                } else {
                    return CLKComplicationTemplateGraphicCornerStackText(ticket: ticket)
                }
            case .graphicRectangular:
                return CLKComplicationTemplateGraphicRectangularStandardBody(ticket: ticket)
            default:
                break
            }
        }
        return nil
    }
    
}

extension Ticket {
    
    static var fake: Ticket {
        let departure = Station(name: "Минск")
        let arrival = Station(name: "Брест")
        let place = Place(carriage: 10, seat: "12")
        return Ticket(sourceStation: departure,
                      destinationStation: arrival,
                      departure: Date(timeIntervalSinceNow: 60 * 60),
                      arrival: Date(timeIntervalSinceNow: 2 * 60 * 60),
                      notes: "",
                      places: [place])
    }
}

extension CLKComplicationTemplateModularSmallColumnsText {
    
    convenience init(ticket: Ticket?) {
        self.init()
        let carriageString: String
        let seatString: String
        if let place = ticket?.places.first {
            carriageString = String(place.carriage)
            seatString = place.seat
        } else {
            carriageString = "-"
            seatString = "-"
        }
        self.row1Column1TextProvider = CLKSimpleTextProvider(text: NSLocalizedString("В", comment: ""))
        self.row1Column2TextProvider = CLKSimpleTextProvider(text: carriageString)
        self.row2Column1TextProvider = CLKSimpleTextProvider(text: NSLocalizedString("М", comment: ""))
        self.row2Column2TextProvider = CLKSimpleTextProvider(text: seatString)
        self.highlightColumn2 = true
    }
}

extension CLKComplicationTemplateModularLargeTable {
    
    convenience init(ticket: Ticket?) {
        self.init()
        let timeProvider: CLKTextProvider
        let carriageString: String
        let placeString: String
        if let ticket = ticket {
            timeProvider = CLKTimeTextProvider(date: ticket.departure)
            if let place = ticket.places.first {
                carriageString = String(place.carriage)
                placeString = place.seat
            } else {
                carriageString = "-"
                placeString = "-"
            }
        } else {
            timeProvider = CLKSimpleTextProvider(text: "--:--")
            carriageString = "-"
            placeString = "-"
        }
        self.headerTextProvider = timeProvider
        self.row1Column1TextProvider = CLKSimpleTextProvider(text: NSLocalizedString("Вагон", comment: ""),
                                                             shortText: NSLocalizedString("В", comment: ""))
        self.row1Column2TextProvider = CLKSimpleTextProvider(text: carriageString)
        self.row2Column1TextProvider = CLKSimpleTextProvider(text: NSLocalizedString("Место", comment: ""),
                                                             shortText: NSLocalizedString("М", comment: ""))
        self.row2Column2TextProvider = CLKSimpleTextProvider(text: placeString)
    }
}

extension CLKComplicationTemplateUtilitarianSmallFlat {
    
    convenience init(ticket: Ticket?) {
        self.init()
        let carriageString: String
        let seatString: String
        if let place = ticket?.places.first {
            carriageString = String(place.carriage)
            seatString = place.seat
        } else {
            carriageString = "-"
            seatString = "-"
        }
        let carriageLong = NSLocalizedString("Вагон", comment: "")
        let seatLong = NSLocalizedString("Место", comment: "")
        let carriageShort = NSLocalizedString("В", comment: "")
        let seatShort = NSLocalizedString("М", comment: "")
        
        let text = [carriageLong, carriageString, seatLong, seatString].joined(separator: " ")
        let shortText = [carriageShort, carriageString, seatShort, seatString].joined(separator: " ")
        self.textProvider = CLKSimpleTextProvider(text: text, shortText: shortText)
    }
}

extension CLKComplicationTemplateUtilitarianLargeFlat {
    
    convenience init(ticket: Ticket?) {
        self.init()
        let carriageString: String
        let seatString: String
        if let place = ticket?.places.first {
            carriageString = String(place.carriage)
            seatString = place.seat
        } else {
            carriageString = "-"
            seatString = "-"
        }
        let carriageLong = NSLocalizedString("Вагон", comment: "")
        let seatLong = NSLocalizedString("Место", comment: "")
        let carriageShort = NSLocalizedString("В", comment: "")
        let seatShort = NSLocalizedString("М", comment: "")

        let text = [carriageLong, carriageString, seatLong, seatString].joined(separator: " ")
        let shortText = [carriageShort, carriageString, seatShort, seatString].joined(separator: " ")
        self.textProvider = CLKSimpleTextProvider(text: text, shortText: shortText)
    }
}

@available(watchOSApplicationExtension 5.0, *)
extension CLKComplicationTemplateGraphicCornerStackText {

    convenience init(ticket: Ticket?) {
        self.init()
        let carriageString: String
        let seatString: String
        let dateTextProvider: CLKTextProvider
        if let ticket = ticket, let place = ticket.places.first {
            if ticket.departure.timeIntervalSinceNow > 60 * 60 * 24 {
                dateTextProvider = CLKDateTextProvider(date: ticket.departure, units: [.day, .month, .weekday])
            } else {
                dateTextProvider = CLKTimeTextProvider(date: ticket.departure)
            }
            carriageString = String(place.carriage)
            seatString = place.seat
        } else {
            dateTextProvider = CLKSimpleTextProvider(text: "--:--")
            carriageString = "-"
            seatString = "-"
        }
        let carriageLong = NSLocalizedString("Вагон", comment: "")
        let seatLong = NSLocalizedString("Место", comment: "")
        let carriageShort = NSLocalizedString("В", comment: "")
        let seatShort = NSLocalizedString("М", comment: "")
        let text = [carriageLong, carriageString, seatLong, seatString].joined(separator: " ")
        let shortText = [carriageShort, carriageString, seatShort, seatString].joined(separator: " ")
        innerTextProvider = dateTextProvider
        outerTextProvider = CLKSimpleTextProvider(text: text, shortText: shortText)
    }
}

@available(watchOSApplicationExtension 5.0, *)
extension CLKComplicationTemplateGraphicCornerGaugeText {

    convenience init(ticket: Ticket) {
        self.init()
        let carriageString: String
        let seatString: String
        if let place = ticket.places.first {
            carriageString = String(place.carriage)
            seatString = place.seat
        } else {
            carriageString = "-"
            seatString = "-"
        }
        let carriageLong = NSLocalizedString("Вагон", comment: "")
        let seatLong = NSLocalizedString("Место", comment: "")
        let carriageShort = NSLocalizedString("В", comment: "")
        let seatShort = NSLocalizedString("М", comment: "")
        let text = [carriageLong, carriageString, seatLong, seatString].joined(separator: " ")
        let shortText = [carriageShort, carriageString, seatShort, seatString].joined(separator: " ")
        outerTextProvider = CLKSimpleTextProvider(text: text, shortText: shortText)
        gaugeProvider = CLKTimeIntervalGaugeProvider(style: .fill, gaugeColors: [UIColor.complicationAccentColor], gaugeColorLocations: [0.5],
                                                     start: ticket.departure, end: ticket.arrival)
    }
}

@available(watchOSApplicationExtension 5.0, *)
extension CLKComplicationTemplateGraphicRectangularStandardBody {

    convenience init(ticket: Ticket?) {
        self.init()
        let carriageString: String
        let seatString: String
        let dateTextProvider: CLKTextProvider
        if let ticket = ticket, let place = ticket.places.first {
            if ticket.departure.timeIntervalSinceNow > 60 * 60 * 24 {
                dateTextProvider = CLKDateTextProvider(date: ticket.departure, units: [.day, .month, .weekday])
            } else {
                dateTextProvider = CLKTimeTextProvider(date: ticket.departure)
            }
            carriageString = String(place.carriage)
            seatString = place.seat
        } else {
            dateTextProvider = CLKSimpleTextProvider(text: "--:--")
            carriageString = "-"
            seatString = "-"
        }
        let carriageLong = NSLocalizedString("Вагон", comment: "")
        let seatLong = NSLocalizedString("Место", comment: "")
        let carriageShort = NSLocalizedString("В", comment: "")
        let seatShort = NSLocalizedString("М", comment: "")
        let text = [carriageLong, carriageString, seatLong, seatString].joined(separator: " ")
        let shortText = [carriageShort, carriageString, seatShort, seatString].joined(separator: " ")
        headerTextProvider = dateTextProvider
        body1TextProvider = CLKSimpleTextProvider(text: text, shortText: shortText)
    }
}
