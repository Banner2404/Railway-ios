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

class SettingsViewController: ViewController {
    
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
    }
}

//MARK: - Private
private extension SettingsViewController {
    
    func setupTableView() {
        let gmailSection = SectionModel(model: "test", items: ["section"])
        let sections = Observable.just([gmailSection])
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(configureCell: { ds, tableView, indexPath, _ in
            let cell = tableView.dequeueReusableCell(withIdentifier: "GmailTableViewCell", for: indexPath)
            return cell
        })
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.tableFooterView = UIView()
        tableView.rx.itemSelected
            .filter { $0.section == 0 }
            .subscribe(onNext: { _ in self.connectGmail() })
            .disposed(by: disposeBag)
    }
    
    func connectGmail() {
        viewModel.signInMail(on: self)
            .subscribe(onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}
