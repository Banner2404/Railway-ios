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
    private var showOldestSection = true
    private var shouldMakeInitialScroll = true
    private var oldTickets: Observable<[TicketViewModel]>!
    private var newTickets: Observable<[TicketViewModel]>!
    private var closestTickets: Observable<[TicketViewModel]>!
    private var futureTickets: Observable<[TicketViewModel]>!
    private var shownTickets: Observable<[[TicketViewModel]]>!
    private weak var activeCell: TicketCollapsedTableViewCell?
    private var transitionAnimator = TicketOpenAnimator()
    private var selectedIndexPath: IndexPath?
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
        navigationController?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(tableView.contentSize)
        setupTableViewInsets()
        if shouldMakeInitialScroll {
            shouldMakeInitialScroll = false
            scrollToInitialPosition()
        }
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
    
    func updateSelectedIndexPath(with detailsViewModel: TicketDetailsViewModel) {
        guard let collapsedViewModel = self.viewModel.ticketViewModel(for: detailsViewModel) else {
            selectedIndexPath = nil
            return
        }
        let indexPath = dataSource.sectionModels.enumerated()
            .flatMap { (sectionIndex, section) in
                section.items.enumerated().map { (rowIndex, item) in
                    (item, IndexPath(row: rowIndex, section: sectionIndex))
                }
            }
            .first { $0.0 === collapsedViewModel }
            .map { $0.1 }
        selectedIndexPath = indexPath
    }
    
    func animatePop() {
        showAllRows()
        guard let selectedIndexPath = selectedIndexPath else { return }
        hideRow(at: selectedIndexPath)
    }
    
    func completePop() {
        showAllRows()
    }
    
    func frameForSelectedCell() -> CGRect? {
        guard let indexPath = selectedIndexPath else { return nil }
        if let cell = tableView.cellForRow(at: indexPath) as? TicketCollapsedTableViewCell {
            let ticketFrame = cell.mainView.convert(cell.mainView.bounds, to: view)
            return ticketFrame
        } else {
            return tableView.rectForRow(at: indexPath)
        }
    }
    
}

//MARK: - Private
private extension TicketListViewController {
    
    func showDetails(with viewModel: TicketDetailsViewModel) {
        hideDeleteButtonIfNeeded()
        let detailController = TicketDetailsViewController.loadFromStoryboard(viewModel)
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    func hideRow(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.alpha = 0
    }
    
    func showAllRows() {
        tableView.visibleCells.forEach { $0.alpha = 1 }
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
        return Observable.combineLatest(oldTickets, closestTickets, futureTickets)
            .map { arguments -> [SectionModel<String, TicketViewModel>] in
                let old = SectionModel(model: NSLocalizedString("Прошедшие", comment: "section title") , items: arguments.0)
                let next = SectionModel(model: NSLocalizedString("Ближайший", comment: "section title"), items: arguments.1)
                let future = SectionModel(model: NSLocalizedString("Будущие", comment: "section title"), items: arguments.2)
                let sections = [old, next, future]
                return sections.filter { $0.items.count > 0 }

            }
    }
    
    func createDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<String, TicketViewModel>> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TicketViewModel>>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCollapsedTableViewCell", for: indexPath) as! TicketCollapsedTableViewCell
                cell.delegate = self
                cell.ticketView.setup(with: item)
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
                self.hideRow(at: indexPath)
                self.selectedIndexPath = indexPath
            })
            .map { self.dataSource.sectionModels[$0.section].items[$0.row] }
            .map { ($0, self.viewModel.detailedTicketViewModel(for: $0)) }
            .subscribe(onNext: { initial, final in
                guard let final = final else { return }
                self.transitionAnimator.initialViewModel = initial
                self.transitionAnimator.finalViewModel = final
                self.showDetails(with: final)})
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
        transitionAnimator.initialFrame = frame
    }
    
    func setupTableViewInsets() {
        if tableView.numberOfSections < 1 { return }
        let visibleHeight = tableView.contentSize.height - tableView.rect(forSection: 0).height + tableView.safeAreaInsets.bottom
        tableView.contentInset.bottom = max(tableView.frame.height - visibleHeight - view.safeAreaInsets.top, 0.0)
    }
    
    func hideDeleteButtonIfNeeded() {
        activeCell?.hideDeleteButton()
        activeCell = nil
    }
    
    func scrollToInitialPosition() {
        if tableView.numberOfSections < 1 { return }
        let contentSize = tableView.contentSize
        let oldestSize = tableView.rect(forSection: 0)
        let scrollRect = CGRect(x: 0, y: oldestSize.maxY, width: contentSize.width, height: contentSize.height - oldestSize.height)
        print(scrollRect)
        tableView.scrollRectToVisible(scrollRect, animated: false)
        self.scrollViewDidScroll(tableView)
        shouldMakeInitialScroll = false
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.white.withAlphaComponent(0.8)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideDeleteButtonIfNeeded()
        if tableView.numberOfSections < 1 { return }
        let contentOffset = scrollView.contentOffset
        let offset = contentOffset.y + scrollView.safeAreaInsets.top
        let oldTicketsHeight = tableView.rect(forSection: 0).height
        if offset > oldTicketsHeight - 100 && showOldestSection {
            showOldestSection = false
            scrollView.contentInset.top = -oldTicketsHeight
            scrollView.contentOffset = contentOffset
            print("Hide")
        } else if offset < oldTicketsHeight - 120 && !showOldestSection {
            showOldestSection = true
            scrollView.contentInset.top = 0
            scrollView.contentOffset = contentOffset
            print("Show")
        }
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
            transitionAnimator.transition = .push
            return transitionAnimator
        } else if fromVC is TicketDetailsViewController, operation == .pop {
            transitionAnimator.transition = .pop
            return transitionAnimator
        } else {
            return nil
        }
    }
    
}
