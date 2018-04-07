//
//  TicketCollapsedTableViewCell.swift
//  Railway
//
//  Created by Евгений Соболь on 4/7/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class TicketCollapsedTableViewCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        mainView.layer.cornerRadius = 10.0
    }
}
