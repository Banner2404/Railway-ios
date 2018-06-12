//
//  DatabaseManager.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

protocol DatabaseManager {
    
    var tickets: BehaviorSubject<[Ticket]> { get }
    func add(_ ticket: Ticket)
    func delete(_ ticket: Ticket)
}


class DefaultDatabaseManager: DatabaseManager {
    
    let tickets = BehaviorSubject<[Ticket]>(value: [])
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
        loadTickets()
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

    func loadTickets() {
        do {
            let tickets = try managedContext
                .fetch(TicketCoreDataModel.fetchRequest())
                .map { Ticket($0 as! TicketCoreDataModel) }
            self.tickets.onNext(tickets)
            print(tickets.map { ($0.arrival.timeIntervalSince1970, $0.departure.timeIntervalSince1970) })
        } catch {
            fatalError("Unable to read from core data \(error)")
        }
    }
    
    func add(_ ticket: Ticket) {
        if let similar = getSimilarTicket(for: ticket).first {
            for place in ticket.places {
                similar.addToPlaces(createEntity(place))
            }
        } else {
            _ = createEntity(ticket)
        }
        saveContext()
        loadTickets()
    }
    
    func delete(_ ticket: Ticket) {
        let request: NSFetchRequest = TicketCoreDataModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", ticket.id)
        do {
            let objects = try managedContext.fetch(request)
            objects.forEach { object in
                self.managedContext.delete(object)
            }
            saveContext()
            loadTickets()
        } catch {
            fatalError("Unable to read from core data \(error)")
        }
    }
    
    private func getSimilarTicket(for ticket: Ticket) -> [TicketCoreDataModel] {
        let request: NSFetchRequest = TicketCoreDataModel.fetchRequest()
        print(ticket.arrival.minuteStart.timeIntervalSince1970)
        print(ticket.arrival.minuteEnd.timeIntervalSince1970)

        request.predicate = NSPredicate(format: "sourceStation.name == %@ AND " +
                                                "destinationStation.name == %@ AND " +
                                                "arrival >= %@ AND arrival <= %@ AND " +
                                                "departure >= %@ AND departure <= %@",
                                        ticket.sourceStation.name,
                                        ticket.destinationStation.name,
                                        ticket.arrival.minuteStart as NSDate,
                                        ticket.arrival.minuteEnd as NSDate,
                                        ticket.departure.minuteStart as NSDate,
                                        ticket.departure.minuteEnd as NSDate)
        do {
            return try managedContext.fetch(request)
        } catch {
            fatalError("Unable to fetch")
        }
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
