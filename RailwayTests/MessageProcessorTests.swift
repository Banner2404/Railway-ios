//
//  MessageProcessorTests.swift
//  MessageProcessorTests
//
//  Created by Евгений Соболь on 6/18/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import XCTest
@testable import Railway

class MessageProcessorTests: XCTestCase {

    func testNormalTicket() {
        let ticket = loadTicket(name: "default")
        XCTAssertFalse(MessageProcessor.process(messageData: ticket).isEmpty)
    }

    func testNewTicket() {
        let ticket = loadTicket(name: "default_new")
        XCTAssertFalse(MessageProcessor.process(messageData: ticket).isEmpty)
    }

    func testOffset3Ticket() {
        let ticket = loadTicket(name: "international_offset_3")
        XCTAssertFalse(MessageProcessor.process(messageData: ticket).isEmpty)
    }

    func testOffset2Ticket() {
        let ticket = loadTicket(name: "print_offset_2")
        XCTAssertFalse(MessageProcessor.process(messageData: ticket).isEmpty)
    }

    func testMultipleTicket() {
        let ticket = loadTicket(name: "multiple")
        XCTAssertEqual(MessageProcessor.process(messageData: ticket).count, 2)
    }
    
    func testMultiplePlacesOnSinglePasport() {
        let ticket = loadTicket(name: "multiple_places_single_passport")
        let tickets = MessageProcessor.process(messageData: ticket)
        XCTAssertEqual(tickets.count, 1)
        XCTAssertEqual(tickets.first?.places.map { $0.seat }, ["28", "29"])
        XCTAssertEqual(tickets.first?.places.map { $0.carriage }, [3, 3])
    }

    func loadTicket(name: String) -> String {
        let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: "pdf")!
        let data = try! Data(contentsOf: url)
        return data.base64EncodedString()
    }

}
