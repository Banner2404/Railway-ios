//
//  DatabaseManager.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import CoreData

protocol DatabaseManager {
    
    func loadTickets() -> [Ticket]
    func create(_ ticket: Ticket)
}


class DefaultDatabaseManager: DatabaseManager {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Railway")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    private var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init() {
        _ = persistentContainer
    }

    
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func loadTickets() -> [Ticket] {
        do {
            return try managedContext
                .fetch(TicketCoreDataModel.fetchRequest())
                .map { Ticket($0 as! TicketCoreDataModel) }
        } catch {
            fatalError("Unable to read from core data \(error)")
        }
    }
    
    func create(_ ticket: Ticket) {
        _ = createEntity(ticket)
        saveContext()
    }
    
    private func createEntity(_ ticket: Ticket) -> TicketCoreDataModel {
        let ticketModel = createEntity(TicketCoreDataModel.self)
        ticketModel.id = ticket.id
        ticketModel.arrival = ticket.arrival as NSDate
        ticketModel.departure = ticket.departure as NSDate
        
        ticketModel.sourceStation = createEntity(ticket.sourceStation)
        ticketModel.destinationStation = createEntity(ticket.destinationStation)
        ticketModel.places = Set(ticket.places.map { createEntity($0) }) as NSSet
        return ticketModel
    }
    
    private func createEntity(_ station: Station) -> StationCoreDataModel {
        let stationModel = createEntity(StationCoreDataModel.self)
        stationModel.id = station.id
        stationModel.name = station.name
        return stationModel
    }
    
    private func createEntity(_ place: Place) -> PlaceCoreDataModel {
        let placeModel = createEntity(PlaceCoreDataModel.self)
        placeModel.id = place.id
        placeModel.carriage = Int64(place.carriage)
        placeModel.seat = place.seat
        return placeModel
    }
    
    private func createEntity<Object: NSManagedObject>(_ object: Object.Type) -> Object {
        return NSManagedObject(entity: object.entity(), insertInto: managedContext) as! Object
    }
}

extension Ticket {
    
    init(_ ticket: TicketCoreDataModel) {
        self.id = ticket.id!
        self.sourceStation = Station(ticket.sourceStation!)
        self.destinationStation = Station(ticket.destinationStation!)
        self.arrival = ticket.arrival! as Date
        self.departure = ticket.departure! as Date
        self.places = ticket.places!.map { Place($0 as! PlaceCoreDataModel) }
    }
}

extension Station {
    
    init(_ station: StationCoreDataModel) {
        self.id = station.id!
        self.name = station.name!
    }
}

extension Place {
    
    init(_ place: PlaceCoreDataModel) {
        self.id = place.id!
        self.carriage = Int(place.carriage)
        self.seat = place.seat!
    }
}
