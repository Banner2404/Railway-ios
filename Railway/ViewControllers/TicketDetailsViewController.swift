//
//  TicketDetailsViewController.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TicketDetailsViewController: ViewController {

    private var shouldGoBack = false
    private let disposeBag = DisposeBag()
    private var viewModel: TicketDetailsViewModel!
    @IBOutlet private weak var ticketView: TicketTransitionView!
    
    class func loadFromStoryboard(_ viewModel: TicketDetailsViewModel) -> TicketDetailsViewController {
        let viewController = loadViewControllerFromStoryboard() as TicketDetailsViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTicketInfo()
        setupActions()
        viewModel.editViewModel
            .subscribe(onNext: { viewModel in
                self.showEditViewController(with: viewModel)
            })
            .disposed(by: disposeBag)
    }
    
    private func deleteButtonTap() {
        let alert = UIAlertController(title: "Удалить Билет?", message: "Вы действительно хотите удалить билет от станции \(viewModel.fromText.value) до станции \(viewModel.toText.value)?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .destructive) { _ in
            self.viewModel.delete()
            self.navigationController?.popViewController(animated: true)
        }
        let noAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    private func editButtonTap() {
        viewModel.edit()
    }
    
    private func showEditViewController(with viewModel: AddTicketViewModel) {
        let viewController = AddTicketViewController.loadFromStoryboard(viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setupTicketInfo() {
        viewModel.stationsText
            .bind(to: ticketView.expandedView.stationsLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.departureTimeText
            .bind(to: ticketView.expandedView.departureLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.arrivalTimeText
            .bind(to: ticketView.expandedView.arrivalLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.dateText
            .bind(to: ticketView.expandedView.dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.notes
            .bind(to: ticketView.expandedView.notesTextView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.notes
            .map { $0.isEmpty }
            .bind(to: ticketView.expandedView.notesView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.places
            .subscribe(onNext: { places in
                self.ticketView.expandedView.places = places.map { place in
                    let view = PlaceView()
                    view.carriageLabel.text = place.carriageText
                    view.seatLabel.text = place.seatText
                    return view
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.collapsedTicketViewModel
            .subscribe(onNext: { vm in
                self.ticketView.collapsedView.setup(with: vm)
            })
            .disposed(by: disposeBag)
    }
    
    func setupActions() {
        ticketView.expandedView.editButton.rx.tap
            .subscribe(onNext: { _ in self.editButtonTap() })
            .disposed(by: disposeBag)
        
        ticketView.expandedView.deleteButton.rx.tap
            .subscribe(onNext: { _ in self.deleteButtonTap() })
            .disposed(by: disposeBag)
    }
}

//MARK: - UIScrollViewDelegate
extension TicketDetailsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = abs(scrollView.contentOffset.y)
        if offset > 60.0 && !shouldGoBack {
            shouldGoBack = true
            ticketView.set(state: .collapsed, animated: true)
        } else if offset <= 30.0 && offset > 1.0 && shouldGoBack {
            shouldGoBack = false
            ticketView.set(state: .expanded, animated: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if shouldGoBack {
            navigationController?.popViewController(animated: true)
        }
    }
}
