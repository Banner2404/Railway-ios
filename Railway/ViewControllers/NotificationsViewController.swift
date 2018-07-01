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
    private var availableAlerts: [NotificationAlert] {
        return viewModel.alerts.value.excluded
    }
    private var hasAvailableAlerts: Observable<Bool> {
        return viewModel.alerts.asObservable()
            .map { $0.excluded.count > 0 }
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
    
    func addButtonTap() {
        footerCells.onNext([.picker, .save])
        resizeTableView()
    }
    
    func cancelButtonTap() {
        footerCells.onNext([.add])
        resizeTableView()
    }
    
    func saveButtonTap() {
        guard let index = pickerView?.selectedRow(inComponent: 0) else { return }
        let alert = availableAlerts[index]
        viewModel.alerts.value.insert(alert)
        footerCells.onNext([.add])
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
    
    func setupSections() -> Observable<[NotificationsSection]> {
        let toggle = Observable.just([NotificationsSection.Item.toggle])
        let alerts = viewModel.alerts.asObservable()
            .map { $0.included.enumerated().map { NotificationsSection.Item.record(alert: $0.element) } }
        let footer = footerCells
        footerCells.onNext([.add])
        return Observable.combineLatest(toggle, alerts, footer) { toggle, alerts, footer in
                return toggle + alerts + footer
            }
            .debug()
            .map { [NotificationsSection(items: $0)] }
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
    }
    
    func setupTableView() {
        let sections = setupSections()
        let dataSource = setupDataSource()
        sections
            .debug()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
    func setupToggle(cell: NotificationsToggleTableViewCell) {
        cell.switchControl.isOn = viewModel.isEnabled.value
        cell.switchControl.rx.isOn
            .bind(to: viewModel.isEnabled)
            .disposed(by: cell.disposeBag)
    }
    
    func setupRecord(cell: NotificationRecordTableViewCell, alert: NotificationAlert, index: Int) {
        cell.valueLabel.text = alert.string
        cell.titleLabel.text = index.string
    }
    
    func setupAdd(cell: NotificationAddAlertTableViewCell) {
        hasAvailableAlerts
            .bind(to: cell.addButton.rx.isEnabled)
            .disposed(by: cell.disposeBag)
        cell.addButton.rx.tap
            .subscribe(onNext: addButtonTap)
            .disposed(by: cell.disposeBag)
    }
    
    func setupPicker(cell: NotificationPickerTableViewCell) {
        cell.pickerView.dataSource = self
        cell.pickerView.delegate = self
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
