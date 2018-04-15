//
//  TicketDetailsViewController.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class TicketDetailsViewController: ViewController {

    private var viewModel: TicketDetailsViewModel!
    @IBOutlet private weak var stationsLabel: UILabel!
    @IBOutlet private weak var departureLabel: UILabel!
    @IBOutlet private weak var arrivalLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    class func loadFromStoryboard(_ viewModel: TicketDetailsViewModel) -> TicketDetailsViewController {
        let viewController = loadFromStoryboard() as TicketDetailsViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTicketInfo()
    }
    
    private func setupTicketInfo() {
        stationsLabel.text = viewModel.stationsText
        departureLabel.text = viewModel.departureTimeText
        arrivalLabel.text = viewModel.arrivalTimeText
        dateLabel.text = viewModel.dateText
    }
}
