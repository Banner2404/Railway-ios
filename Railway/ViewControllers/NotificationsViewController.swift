//
//  NotificationsViewController.swift
//  Railway
//
//  Created by Евгений Соболь on 6/24/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationsViewController: ViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    class func loadFromStoryboard() -> NotificationsViewController {
        let viewController = loadViewControllerFromStoryboard() as NotificationsViewController
        return viewController
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("TEST:", "childWillLayout")
        tableView.reloadData()
        adjustTableViewHeight()
    }
    
    private func adjustTableViewHeight() {
        tableViewHeightConstraint.constant = tableView.contentSize.height
        print("Child", tableView.contentSize.height)
    }
}

//MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Load table")
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "test", for: indexPath)
    }
}
