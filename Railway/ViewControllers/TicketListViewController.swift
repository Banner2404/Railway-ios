//
//  TicketListViewController.swift
//  Railway
//
//  Created by Евгений Соболь on 4/3/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TicketListViewController: ViewController {

    private var viewModel: TicketListViewModel!
    private let disposeBag = DisposeBag()
    private let showOldest = BehaviorRelay<Bool>(value: false)
    @IBOutlet private weak var tableView: UITableView!
    
    class func loadFromStoryboard(viewModel: TicketListViewModel) -> TicketListViewController {
        let viewController = loadViewControllerFromStoryboard() as TicketListViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TicketViewModel>>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCollapsedTableViewCell", for: indexPath) as! TicketCollapsedTableViewCell
                cell.dateLabel.text = item.dateText
                cell.routeLabel.text = item.routeText
                return cell
            })
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }
        let allSections = Observable.combineLatest(createPastSection(),
                                                   createFutureSection(),
                                                   showOldest)
            .map { arg -> [SectionModel<String, TicketViewModel>] in
                if arg.2 {
                    return [arg.0, arg.1]
                } else {
                    return [arg.1]
                }
                
        }
        allSections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.tableFooterView = UIView()
        tableView.rx.itemSelected
            .map { self.viewModel.ticketViewModel(at: $0.section) }
            .subscribe(onNext: { viewModel in
                self.showDetails(with: viewModel)})
            .disposed(by: disposeBag)
        setupPullToOldest()
    }
    
    @IBAction private func addButtonTap(_ sender: Any) {
        let viewController = AddTicketViewController.loadFromStoryboard(viewModel.addViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func settingsButtonTap(_ sender: Any) {
        let viewController = SettingsViewController.loadFromStoryboard()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showDetails(with viewModel: TicketDetailsViewModel) {
        let detailController = TicketDetailsViewController.loadFromStoryboard(viewModel)
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    private func createFutureSection() -> Observable<SectionModel<String, TicketViewModel>> {
        return viewModel.futureTickets.map { SectionModel(model: "Новые", items: $0) }
    }
    
    private func createPastSection() -> Observable<SectionModel<String, TicketViewModel>> {
        return viewModel.pastTickets.map { SectionModel(model: "Старые", items: $0) }
    }
    
    @objc
    private func loadOldest() {
        showOldest.accept(true)
    }
    
    private func setupPullToOldest() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        refreshControl.addTarget(self, action: #selector(loadOldest), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}

//MARK: - UITableViewDelegate
extension TicketListViewController: UITableViewDelegate {
}
