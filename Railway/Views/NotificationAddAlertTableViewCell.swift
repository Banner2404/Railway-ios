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

class NotificationAddAlertTableViewCell: DisposableTableViewCell {

    @IBOutlet weak var addButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        addButton.setTitleColor(.navigationBarTint, for: .normal)
    }
}
