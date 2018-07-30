//
//  TodayViewController.swift
//  RailwayWidget
//
//  Created by Евгений Соболь on 7/30/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    private let database = DefaultDatabaseManager()
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let ticket = database.getNextTicket()
        label.text = ticket?.places.first.map { "\($0.carriage) вагон \($0.seat) место"} ?? "no data"
        completionHandler(NCUpdateResult.newData)
    }
    
}
