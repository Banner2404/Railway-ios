//
//  NotificationRecordTableViewCell.swift
//  Railway
//
//  Created by Евгений Соболь on 6/24/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class NotificationRecordTableViewCell: DisposableTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .text
    }
}
