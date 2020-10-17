//
//  SettingsViewController.swift
//  Railway
//
//  Created by Евгений Соболь on 6/3/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import GoogleSignIn

class SettingsViewController: ViewController, ContainerViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private let disposeBag = DisposeBag()
    private var viewModel: SettingsViewModel!
    
    class func loadFromStoryboard(viewModel: SettingsViewModel) -> SettingsViewController {
        let viewController = loadViewControllerFromStoryboard() as SettingsViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        view.backgroundColor = .tableBackground
    }
}

//MARK: - Private
private extension SettingsViewController {
    
    func setupTableView() {
        let gmailConnectSection = Observable.just(SettingsSection(items: [.gmailConnect]))
        let gmailDisconnectSection = Observable.just(SettingsSection(items: [.gmailDisconnect]))

        let sections = Observable.combineLatest(gmailConnectSection, gmailDisconnectSection, viewModel!.isGmailConnected)
            .map { arg -> [SettingsSection] in
                if arg.2 {
                    return [arg.1]
                } else {
                    return [arg.0]
                }
            }
            .map { [SettingsSection(items: [.notifications])] + $0 }
        
        let dataSource = RxTableViewSectionedReloadDataSource<SettingsSection>(configureCell: { ds, tableView, indexPath, model in
            let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier, for: indexPath)
            if model == .notifications, let cell = cell as? NotificationSettingsTableViewCell {
                self.setupNotiticationsViewController(in: cell.mainView)
            }
            return cell
        })
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.tableFooterView = UIView()
        tableView.rx.itemSelected
            .filter { dataSource.sectionModels[$0.section].items[$0.item] == .gmailConnect }
            .subscribe(onNext: { _ in self.connectGmail() })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .filter { dataSource.sectionModels[$0.section].items[$0.item] == .gmailDisconnect }
            .subscribe(onNext: { _ in self.disconnectGmail() })
            .disposed(by: disposeBag)
        
    }
    
    func connectGmail() {
        viewModel.signInMail(on: self)
            .subscribe(onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    func disconnectGmail() {
        viewModel.signOutMail()
    }
    
    private func setupNotiticationsViewController(in view: UIView) {
        let viewModel = self.viewModel.getNotificationsViewModel()
        let viewController = NotificationsViewController.loadFromStoryboard(viewModel: viewModel)
        show(viewController, inContainerView: view)
        
        viewController.resizeCell
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            })
            .disposed(by: disposeBag)

        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()
    }
}
