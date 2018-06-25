//
//  NotificationAddAlertTableViewCell.swift
//  Railway
//
//  Created by Евгений Соболь on 6/25/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationAddAlertTableViewCell: UITableViewCell {
    
    var tap: ControlEvent<Void> {
        return addButton.rx.tap
    }
    @IBOutlet private weak var addButton: UIButton!

}
