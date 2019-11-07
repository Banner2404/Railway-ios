//
//  NavigationController.swift
//  Railway
//
//  Created by Евгений Соболь on 8/20/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = .navigationBarBackground
        navigationBar.tintColor = .navigationBarTint
    }

}
