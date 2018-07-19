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

    var initialFrame: CGRect = .zero
    
    private var shouldGoBack = false
    private let disposeBag = DisposeBag()
    private var viewModel: TicketDetailsViewModel!
    private var startPoint = CGPoint.zero
    @IBOutlet weak var ticketView: TicketTransitionView!
    @IBOutlet private weak var ticketContainer: UIView!
    @IBOutlet private weak var viewTopConstraint: NSLayoutConstraint!
    private let SnapAnimationDuration = 2.0
    
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
    
    func animateAppearance() {
        view.layoutIfNeeded()
        view.backgroundColor = UIColor.clear
        ticketContainer.backgroundColor = UIColor.clear
        let finalFrame = ticketView.convert(ticketView.bounds, to: view)
        let offset = initialFrame.minY - finalFrame.minY
        viewTopConstraint.constant = offset
        view.layoutIfNeeded()
        ticketView.set(state: .expanded, animated: true)
        viewTopConstraint.constant = 0
        UIView.animate(withDuration: SnapAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func viewDragged(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            startPoint = sender.location(in: view)
        case .changed:
            let location = sender.location(in: view)
            let yDiff = location.y - startPoint.y
            viewTopConstraint.constant = yDiff
            if yDiff > 120.0 && !shouldGoBack {
                shouldGoBack = true
                ticketView.set(state: .collapsed, animated: true)
            } else if yDiff < 80.0 && shouldGoBack {
                shouldGoBack = false
                ticketView.set(state: .expanded, animated: true)
            }
        case .ended, .failed:
            if shouldGoBack {
                let finalFrame = ticketContainer.convert(initialFrame, from: view)
                UIView.animate(withDuration: SnapAnimationDuration) {
                    self.ticketView.frame = finalFrame
                }
            } else {
                viewTopConstraint.constant = 0
                UIView.animate(withDuration: SnapAnimationDuration) {
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }
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
