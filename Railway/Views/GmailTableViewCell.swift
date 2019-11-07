//
//  GmailTableViewCell.swift
//  Railway
//
//  Created by Евгений Соболь on 6/12/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class GmailTableViewCell: HighlightableTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.textColor = .text
    }

}
