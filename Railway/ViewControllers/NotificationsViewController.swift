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

    var resizeCell: Observable<Void> {
        return resizeCellSubject.asObservable()
    }
    
    private let resizeCellSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    private var viewModel: NotificationsViewModel!
    private let footerCells = ReplaySubject<[NotificationsSection.Item]>.create(bufferSize: 1)
    private var tableType = TableType.closed {
        didSet {
            tableTypeDidUpdate()
        }
    }
    private var availableAlerts: [NotificationAlert] {
        return viewModel.alerts.value.excluded
    }
    private weak var pickerView: UIPickerView?
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    class func loadFromStoryboard(viewModel: NotificationsViewModel) -> NotificationsViewController {
        let viewController = loadViewControllerFromStoryboard() as NotificationsViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableTypeDidUpdate()
        setupTableView()
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustTableViewHeight()
    }
}

//MARK: - Private
private extension NotificationsViewController {
    
    func toggleValueChanged(enabled: Bool) {
        if enabled == viewModel.isEnabled.value { return }
        viewModel.isEnabled.value = enabled
        resizeTableView()
    }
    
    func addButtonTap() {
        tableType = .open
        resizeTableView()
    }
    
    func cancelButtonTap() {
        tableType = .closed
        resizeTableView()
    }
    
    func delete(alert: NotificationAlert) {
        viewModel.alerts.value.remove(alert)
        resizeTableView()
    }
    
    func saveButtonTap() {
        guard let index = pickerView?.selectedRow(inComponent: 0) else { return }
        let alert = availableAlerts[index]
        viewModel.alerts.value.insert(alert)
        tableType = .closed
        resizeTableView()
    }
    
    func resizeTableView() {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        adjustTableViewHeight()
        resizeCellSubject.onNext(())
    }
    
    func adjustTableViewHeight() {
        let height = tableView.contentSize.height
        tableViewHeightConstraint.constant = height
    }
    
    func tableTypeDidUpdate() {
        switch tableType {
        case .closed:
            if availableAlerts.count > 0 {
                footerCells.onNext([.add])
            } else {
                footerCells.onNext([])
            }
        case .open:
            footerCells.onNext([.picker, .save])
        }
    }
    
    func setupSections() -> Observable<[NotificationsSection]> {
        let toggle = Observable.just([NotificationsSection.Item.toggle])
        let alerts = viewModel.alerts.asObservable()
            .map { $0.included.enumerated().map { NotificationsSection.Item.record(alert: $0.element) } }
        let footer = footerCells
        let enabled = viewModel.isEnabled.asObservable().distinctUntilChanged()
        return Observable.combineLatest(enabled, toggle, alerts, footer) { enabled, toggle, alerts, footer in
                if enabled {
                    return toggle + alerts + footer
                } else {
                    return toggle
                }
            }
            .map { [NotificationsSection(items: $0)] }
    }
    
    func setupDataSource() -> RxTableViewSectionedReloadDataSource<NotificationsSection> {
        let dataSource = RxTableViewSectionedReloadDataSource<NotificationsSection>(configureCell: { (ds, tableView, index, model) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier, for: index)
            if let cell = cell as? NotificationsToggleTableViewCell {
                self.setupToggle(cell: cell)
            }
            if let cell = cell as? NotificationRecordTableViewCell, case .record(let alert) = model {
                self.setupRecord(cell: cell, alert: alert, index: index.row)
            }
            if let cell = cell as? NotificationAddAlertTableViewCell {
                self.setupAdd(cell: cell)
            }
            if let cell = cell as? NotificationPickerTableViewCell {
                self.setupPicker(cell: cell)
            }
            if let cell = cell as? NotificationSaveTableViewCell {
                self.setupSave(cell: cell)
            }
            return cell
        })
        
        dataSource.canEditRowAtIndexPath = { ds, index in
            guard let model = (try? dataSource.model(at: index)) as? NotificationsSection.Item else { return false }
            switch model {
            case .record(_):
                return true
            default:
                return false
            }
        }
        return dataSource
    }
    
    func setupTableView() {
        let sections = setupSections()
        let dataSource = setupDataSource()
        sections
            .debug()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .map { indexPath in
                return dataSource.sectionModels[indexPath.section].items[indexPath.row]
            }
            .flatMap { item -> Observable<NotificationAlert> in
                switch item {
                case .record(let alert):
                    return Observable<NotificationAlert>.just(alert)
                default:
                    return  Observable<NotificationAlert>.empty()
                }
            }
            .subscribe(onNext: { [weak self] alert in
                self?.delete(alert: alert)
            })
            .disposed(by: disposeBag)
        
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    func setupToggle(cell: NotificationsToggleTableViewCell) {
        cell.switchControl.isOn = viewModel.isEnabled.value
        cell.switchControl.rx.isOn
            .subscribe(onNext: { [weak self] enabled in
                self?.toggleValueChanged(enabled: enabled)
            })
            .disposed(by: disposeBag)
    }
    
    func setupRecord(cell: NotificationRecordTableViewCell, alert: NotificationAlert, index: Int) {
        cell.valueLabel.text = alert.string
        cell.titleLabel.text = index.string
    }
    
    func setupAdd(cell: NotificationAddAlertTableViewCell) {
        cell.addButton.rx.tap
            .subscribe(onNext: addButtonTap)
            .disposed(by: cell.disposeBag)
    }
    
    func setupPicker(cell: NotificationPickerTableViewCell) {
        cell.pickerView.dataSource = self
        cell.pickerView.delegate = self
        cell.pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView = cell.pickerView
    }
    
    func setupSave(cell: NotificationSaveTableViewCell) {
        cell.cancelTap
            .subscribe(onNext: { [weak self] _ in
                self?.cancelButtonTap()
            })
            .disposed(by: cell.disposeBag)
        
        cell.saveTap
            .subscribe(onNext: { [weak self] _ in
                self?.saveButtonTap()
            })
            .disposed(by: cell.disposeBag)
    }
    
    enum TableType {
        case closed
        case open
    }
}

//MARK: - UIPickerViewDataSource
extension NotificationsViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableAlerts.count
    }
    
}

//MARK: - UIPickerViewDelegate
extension NotificationsViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let alert = availableAlerts[row]
        return alert.string
    }
}

//MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}
