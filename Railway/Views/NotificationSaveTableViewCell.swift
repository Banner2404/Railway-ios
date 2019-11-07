//
//  NotificationSaveTableViewCell.swift
//  Railway
//
//  Created by Евгений Соболь on 7/1/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationSaveTableViewCell: DisposableTableViewCell {
    
    var saveTap: ControlEvent<Void> {
        return saveButton.rx.tap
    }
    
    var cancelTap: ControlEvent<Void> {
        return cancelButton.rx.tap
    }

    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        cancelButton.setTitleColor(.navigationBarTint, for: .normal)
        saveButton.setTitleColor(.navigationBarTint, for: .normal)
    }
}
