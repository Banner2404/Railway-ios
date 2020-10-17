//
//  HighlightableTableViewCell.swift
//  Railway
//
//  Created by Евгений Соболь on 6/12/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class HighlightableTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        mainView?.backgroundColor = .cardBackground
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {}

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 1.0) {
                self.updateBackground(highlighted: highlighted)
            }
        } else {
            updateBackground(highlighted: highlighted)
        }
    }
    
    private func updateBackground(highlighted: Bool) {
        self.alpha = highlighted ? 0.75 : 1.0
    }
}
