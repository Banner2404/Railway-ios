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
    func update(_ ticket: Ticket)
    func delete(_ ticket: Ticket)
    
    func getNotificationSettings() -> (isEnabled: Bool, alerts: NotificationAlert)?
    func saveNotificationSettings(isEnabled: Bool, alerts: NotificationAlert)
    
    func getNextTicket() -> Ticket?
}


class DefaultDatabaseManager: DatabaseManager {
    
    let tickets = BehaviorSubject<[Ticket]>(value: [])
    private lazy var persistentContainer: NSPersistentContainer = {
        let appName = "Railway"
        let container = NSPersistentContainer(name: appName)
        let containerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.esobol.\(appName)")!
        let storeUrl = containerUrl.appendingPathComponent("\(appName).sqlite")
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeUrl)]
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

    func loadTickets() {
        #if MOCK_DATA
            loadFakeTickets()
            return
        #endif
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
    
    func update(_ ticket: Ticket) {
        guard let model = getModel(for: ticket) else { return }
        model.sourceStation = createEntity(ticket.sourceStation)
        model.destinationStation = createEntity(ticket.destinationStation)
        model.departure = ticket.departure as NSDate
        model.arrival = ticket.arrival as NSDate
        model.notes = ticket.notes
        if let places = model.places {
            model.removeFromPlaces(places)
        }
        ticket.places
            .map { createEntity($0) }
            .forEach { model.addToPlaces($0) }
        saveContext()
        loadTickets()
    }
    
    func delete(_ ticket: Ticket) {
        guard let model = getModel(for: ticket) else { return }
        managedContext.delete(model)
        saveContext()
        loadTickets()
    }
    
    func getNotificationSettings() -> (isEnabled: Bool, alerts: NotificationAlert)? {
        let request: NSFetchRequest = NotificationSettingsCoreDataModel.fetchRequest()
        guard let settings = (try? managedContext.fetch(request))?.first else { return nil }
        let alerts = NotificationAlert(rawValue: Int(settings.rawValue))
        return (settings.isEnabled, alerts)
    }
    
    func saveNotificationSettings(isEnabled: Bool, alerts: NotificationAlert) {
        clearNotificationSettings()
        let settings = createEntity(NotificationSettingsCoreDataModel.self)
        settings.isEnabled = isEnabled
        settings.rawValue = Int64(alerts.rawValue)
        saveContext()
    }
    
    func getNextTicket() -> Ticket? {
        do {
            let entityName = String(describing: TicketCoreDataModel.self)
            let request: NSFetchRequest<TicketCoreDataModel> = NSFetchRequest(entityName: entityName)
            request.predicate = NSPredicate(format: "arrival > %@", Date() as NSDate)
            request.sortDescriptors = [NSSortDescriptor(key: "arrival", ascending: true)]
            request.fetchLimit = 1
            let tickets = try managedContext
                .fetch(request)
                .map { Ticket($0) }
            return tickets.first
        } catch {
            fatalError("Unable to read from core data \(error)")
        }
    }
    
    private func clearNotificationSettings() {
        let request: NSFetchRequest = NotificationSettingsCoreDataModel.fetchRequest()
        guard let objects = try? managedContext.fetch(request) else { return }
        for object in objects {
            managedContext.delete(object)
        }
        saveContext()
    }
    
    private func getModel(for ticket: Ticket) -> TicketCoreDataModel? {
        let request: NSFetchRequest = TicketCoreDataModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", ticket.id)
        do {
            return try managedContext.fetch(request).first
        } catch {
            fatalError("Unable to read from core data \(error)")
        }
    }
    
    private func getSimilarTicket(for ticket: Ticket) -> [TicketCoreDataModel] {
        let request: NSFetchRequest = TicketCoreDataModel.fetchRequest()

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
        ticketModel.notes = ticket.notes
        
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
        self.notes = ticket.notes ?? ""
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

#if MOCK_DATA
extension DatabaseManager {
    
    func loadFakeTickets() {
        let minsk = Station(name: "Минск")
        let minskPass = Station(name: "Минск-Пассажирский")
        let vitebsk = Station(name: "Витебск")
        let bereza = Station(name: "Береза")
        let gomel = Station(name: "Гомель")
        let brest = Station(name: "Брест")
        let grodno = Station(name: "Гродно")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        let ticket1 = Ticket(sourceStation: minsk,
                             destinationStation: vitebsk,
                             departure: formatter.date(from: "25.08.2018 20:29")!,
                             arrival: formatter.date(from: "25.08.2018 20:30")!,
                             notes: "", places: [])
        
        let ticket2 = Ticket(sourceStation: bereza,
                             destinationStation: gomel,
                             departure: formatter.date(from: "25.08.2018 23:00")!,
                             arrival: formatter.date(from: "25.08.2018 23:30")!,
                             notes: "", places: [])
        
        let ticket3 = Ticket(sourceStation: minskPass,
                             destinationStation: brest,
                             departure: formatter.date(from: "10.09.2018 10:00")!,
                             arrival: formatter.date(from: "10.09.2018 23:30")!,
                             notes: "Телефон\nДеньги\nПаспорт",
                             places: [Place(carriage: 1, seat: "23")])
        
        let ticket4 = Ticket(sourceStation: gomel,
                             destinationStation: grodno,
                             departure: formatter.date(from: "13.09.2018 14:23")!,
                             arrival: formatter.date(from: "13.09.2018 18:30")!,
                             notes: "",
                             places: [Place(carriage: 9, seat: "23"), Place(carriage: 9, seat: "24")])
        
        tickets.onNext([ticket1, ticket2, ticket3, ticket4])
    }
}

#endif
