//
//  StationCoreDataModel+CoreDataProperties.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//
//

import Foundation
import CoreData


extension StationCoreDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StationCoreDataModel> {
        return NSFetchRequest<StationCoreDataModel>(entityName: "StationCoreDataModel")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var destTicket: TicketCoreDataModel?
    @NSManaged public var sourceTicket: TicketCoreDataModel?

}
