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
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication,
                                          withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication,
                                 withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        
        switch complication.family {
        case .modularSmall:
            guard let place = TicketsStorage.shared.tickets.first?.places.first else {
                handler(nil)
                return
            }
            let template = CLKComplicationTemplateModularSmallColumnsText()
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "В")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: String(place.carriage))
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "М")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: place.seat)
            template.highlightColumn2 = true
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)

        default:
            handler(nil)
        }
    }
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallColumnsText()
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "В")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "12")
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "М")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "10")
            template.highlightColumn2 = true
            handler(template)
            
        default:
            handler(nil)
        }
    }
    
    
    
}
