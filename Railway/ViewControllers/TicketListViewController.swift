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
    private var oldTickets: Observable<[TicketViewModel]>!
    private var newTickets: Observable<[TicketViewModel]>!
    private var closestTickets: Observable<[TicketViewModel]>!
    private var futureTickets: Observable<[TicketViewModel]>!

    private var shownTickets: Observable<[[TicketViewModel]]>!

    @IBOutlet private weak var syncIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    class func loadFromStoryboard(viewModel: TicketListViewModel) -> TicketListViewController {
        let viewController = loadViewControllerFromStoryboard() as TicketListViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oldTickets = viewModel.allTickets
            .map { tickets in
                tickets.filter { ticket in
                    ticket.referenceDate < Date()
                }
        }
        
        newTickets = viewModel.allTickets
            .map { tickets in
                tickets.filter { ticket in
                    ticket.referenceDate >= Date()
                }
            }
        
        closestTickets = newTickets
            .map { [$0.first].compactMap { $0 } }
        
        futureTickets = newTickets
            .map { Array($0.dropFirst()) }
        
        let allSections = Observable.combineLatest(oldTickets, closestTickets, futureTickets, showOldest)
            .map { arguments -> [SectionModel<String, TicketViewModel>] in
                let old = SectionModel(model: "Старые", items: arguments.0)
                let next = SectionModel(model: "Ближайший", items: arguments.1)
                let future = SectionModel(model: "Будущие", items: arguments.2)
                
                if arguments.3 {
                    
                    return [old, next, future]
                } else {
                    return [next, future]
                }
        }
        
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
        
        allSections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.tableFooterView = UIView()
        tableView.rx.itemSelected
            .map { dataSource.sectionModels[$0.section].items[$0.row] }
            .map { self.viewModel.detailedTicketViewModel(for: $0) }
            .subscribe(onNext: { viewModel in
                guard let viewModel = viewModel else { return }
                self.showDetails(with: viewModel)})
            .disposed(by: disposeBag)
        
        viewModel.isSyncronizing
            .debug()
            .map { !$0 }
            .bind(to: syncIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        setupPullToOldest()
    }
    
    @IBAction private func addButtonTap(_ sender: Any) {
        let viewController = AddTicketViewController.loadFromStoryboard(viewModel.addViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func settingsButtonTap(_ sender: Any) {
        let viewController = SettingsViewController.loadFromStoryboard(viewModel: viewModel.settingsViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showDetails(with viewModel: TicketDetailsViewModel) {
        let detailController = TicketDetailsViewController.loadFromStoryboard(viewModel)
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    @objc
    private func loadOldest() {
        showOldest.accept(true)
        tableView.refreshControl?.endRefreshing()
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
