//
//  GmailTableViewCell.swift
//  Railway
//
//  Created by Евгений Соболь on 6/12/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import GoogleSignIn

class GmailTableViewCell: HighlightableTableViewCell {

    @IBOutlet weak var signInButton: GIDSignInButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        signInButton.style = .wide
    }
}
