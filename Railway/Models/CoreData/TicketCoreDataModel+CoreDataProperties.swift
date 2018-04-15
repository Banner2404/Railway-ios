//
//  TicketCoreDataModel+CoreDataProperties.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//
//

import Foundation
import CoreData


extension TicketCoreDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TicketCoreDataModel> {
        return NSFetchRequest<TicketCoreDataModel>(entityName: "TicketCoreDataModel")
    }

    @NSManaged public var arrival: NSDate?
    @NSManaged public var departure: NSDate?
    @NSManaged public var id: String?
    @NSManaged public var destinationStation: StationCoreDataModel?
    @NSManaged public var places: NSSet?
    @NSManaged public var sourceStation: StationCoreDataModel?

}

// MARK: Generated accessors for places
extension TicketCoreDataModel {

    @objc(addPlacesObject:)
    @NSManaged public func addToPlaces(_ value: PlaceCoreDataModel)

    @objc(removePlacesObject:)
    @NSManaged public func removeFromPlaces(_ value: PlaceCoreDataModel)

    @objc(addPlaces:)
    @NSManaged public func addToPlaces(_ values: NSSet)

    @objc(removePlaces:)
    @NSManaged public func removeFromPlaces(_ values: NSSet)

}
