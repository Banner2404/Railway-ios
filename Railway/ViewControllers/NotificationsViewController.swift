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
import RxDataSources

class NotificationsViewController: ViewController {

    private let disposeBag = DisposeBag()
    private var viewModel: NotificationsViewModel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    class func loadFromStoryboard(viewModel: NotificationsViewModel) -> NotificationsViewController {
        let viewController = loadViewControllerFromStoryboard() as NotificationsViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("TEST:", "childWillLayout")
        adjustTableViewHeight()
    }
}

//MARK: - Private
private extension NotificationsViewController {
    
    func adjustTableViewHeight() {
        tableViewHeightConstraint.constant = tableView.contentSize.height
        print("Child", tableView.contentSize.height)
    }
    
    func setupSections() -> Observable<[NotificationsSection]> {
        return viewModel.alerts.asObservable()
            .map { $0.included.enumerated().map { NotificationsSection.Item.record(alert: $0.element) } }
            .map { [NotificationsSection(items: [.toggle] + $0)] }
    }
    
    func setupDataSource() -> RxTableViewSectionedReloadDataSource<NotificationsSection> {
        return RxTableViewSectionedReloadDataSource(configureCell: { (ds, tableView, index, model) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier, for: index)
            if let cell = cell as? NotificationsToggleTableViewCell {
                self.setupToggle(cell: cell)
            }
            if let cell = cell as? NotificationRecordTableViewCell, case .record(let alert) = model {
                self.setupRecord(cell: cell, alert: alert, index: index.row)
            }
            return cell
        })
    }
    
    func setupTableView() {
        let sections = setupSections()
        let dataSource = setupDataSource()
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
    func setupToggle(cell: NotificationsToggleTableViewCell) {
        cell.switchControl.isOn = viewModel.isEnabled.value
        cell.switchControl.rx.isOn
            .bind(to: viewModel.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func setupRecord(cell: NotificationRecordTableViewCell, alert: NotificationAlert, index: Int) {
        cell.valueLabel.text = alert.string
        cell.titleLabel.text = index.string
    }
}
