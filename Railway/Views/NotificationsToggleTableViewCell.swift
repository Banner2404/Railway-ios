//
//  NotificationsToggleTableViewCell.swift
//  Railway
//
//  Created by Евгений Соболь on 6/24/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class NotificationsToggleTableViewCell: DisposableTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .text
        switchControl.onTintColor = .switchTint
    }
}
