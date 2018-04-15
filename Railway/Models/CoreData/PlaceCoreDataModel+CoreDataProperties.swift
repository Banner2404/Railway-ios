//
//  PlaceCoreDataModel+CoreDataProperties.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//
//

import Foundation
import CoreData


extension PlaceCoreDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaceCoreDataModel> {
        return NSFetchRequest<PlaceCoreDataModel>(entityName: "PlaceCoreDataModel")
    }

    @NSManaged public var carriage: Int64
    @NSManaged public var seat: String?
    @NSManaged public var id: String?
    @NSManaged public var ticket: TicketCoreDataModel?

}
