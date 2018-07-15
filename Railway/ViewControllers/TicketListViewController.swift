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
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, TicketViewModel>>!
    private let showOldest = BehaviorRelay<Bool>(value: false)
    private var oldTickets: Observable<[TicketViewModel]>!
    private var newTickets: Observable<[TicketViewModel]>!
    private var closestTickets: Observable<[TicketViewModel]>!
    private var futureTickets: Observable<[TicketViewModel]>!
    private var shownTickets: Observable<[[TicketViewModel]]>!
    private weak var activeCell: TicketCollapsedTableViewCell?
    private var transitionAnimator = TicketOpenAnimator()
    @IBOutlet private weak var syncIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    class func loadFromStoryboard(viewModel: TicketListViewModel) -> TicketListViewController {
        let viewController = loadViewControllerFromStoryboard() as TicketListViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTickets()
        setupTableView()
        setupActivityIndicator()
        setupPullToOldest()
        navigationController?.delegate = self
    }
    
    @IBAction private func addButtonTap(_ sender: Any) {
        hideDeleteButtonIfNeeded()
        let viewController = AddTicketViewController.loadFromStoryboard(viewModel.addViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction private func settingsButtonTap(_ sender: Any) {
        hideDeleteButtonIfNeeded()
        let viewController = SettingsViewController.loadFromStoryboard(viewModel: viewModel.settingsViewModel())
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}

//MARK: - Private
private extension TicketListViewController {
    
    func showDetails(with viewModel: TicketDetailsViewModel) {
        hideDeleteButtonIfNeeded()
        let detailController = TicketDetailsViewController.loadFromStoryboard(viewModel)
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    @objc func loadOldest() {
        showOldest.accept(true)
        tableView.refreshControl?.endRefreshing()
    }
    
    func setupPullToOldest() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        refreshControl.addTarget(self, action: #selector(loadOldest), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func setupTickets() {
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
    }
    
    func createSections() -> Observable<[SectionModel<String, TicketViewModel>]> {
        return Observable.combineLatest(oldTickets, closestTickets, futureTickets, showOldest)
            .map { arguments -> [SectionModel<String, TicketViewModel>] in
                let old = SectionModel(model: "Прошедшие", items: arguments.0)
                let next = SectionModel(model: "Ближайший", items: arguments.1)
                let future = SectionModel(model: "Будущие", items: arguments.2)
                
                let sections: [SectionModel<String, TicketViewModel>]
                if arguments.3 {
                    sections = [old, next, future]
                } else {
                    sections = [next, future]
                }
                return sections.filter { $0.items.count > 0 }
        }
    }
    
    func createDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<String, TicketViewModel>> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TicketViewModel>>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCollapsedTableViewCell", for: indexPath) as! TicketCollapsedTableViewCell
                cell.delegate = self
                cell.dateLabel.text = item.dateText
                cell.routeLabel.text = item.routeText
                return cell
        })
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }
        
        return dataSource
    }
    
    func setupTableView() {
        let allSections = createSections()
        self.dataSource = createDataSource()
        
        allSections.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.rx.itemSelected
            .do(onNext: { indexPath in
                self.updateAnimatorInitialFrame(for: indexPath)
            })
            .map { self.dataSource.sectionModels[$0.section].items[$0.row] }
            .map { self.viewModel.detailedTicketViewModel(for: $0) }
            .subscribe(onNext: { viewModel in
                guard let viewModel = viewModel else { return }
                self.showDetails(with: viewModel)})
            .disposed(by: disposeBag)
    }
    
    func setupActivityIndicator() {
        viewModel.isSyncronizing
            .debug()
            .map { !$0 }
            .bind(to: syncIndicator.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    func updateAnimatorInitialFrame(for selectedIndexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: selectedIndexPath) as? TicketCollapsedTableViewCell else { return }
        let cellContentView = cell.mainView!
        let frame = view.convert(cellContentView.bounds, from: cellContentView)
        let snapshot = cell.mainView.snapshotView(afterScreenUpdates: false)
        transitionAnimator.initialView = snapshot
        transitionAnimator.initialFrame = frame
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
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideDeleteButtonIfNeeded()
    }
    
    func hideDeleteButtonIfNeeded() {
        activeCell?.hideDeleteButton()
        activeCell = nil
    }
}

//MARK: - TicketCollapsedTableViewCellDelegate
extension TicketListViewController: TicketCollapsedTableViewCellDelegate {
    
    func ticketCollapsedTableViewCellDidShowDeleteButton(_ cell: TicketCollapsedTableViewCell) {
        if cell === activeCell { return }
        activeCell?.hideDeleteButton()
        activeCell = cell
    }
    
    func ticketCollapsedTableViewCellDidTapDeleteButton(_ cell: TicketCollapsedTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let viewModel = dataSource.sectionModels[indexPath.section].items[indexPath.row]
        self.viewModel.deleteTicket(viewModel: viewModel)
        
    }
}

//MARK: - UINavigationControllerDelegate
extension TicketListViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC is TicketDetailsViewController, operation == .push {
            return transitionAnimator
        } else {
            return nil
        }
    }
    
}
