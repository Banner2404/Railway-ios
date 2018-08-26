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
    var animator: TicketOpenAnimator?
    private(set) var viewModel: TicketDetailsViewModel!

    private var shouldGoBack = false
    private let disposeBag = DisposeBag()
    private var startPoint = CGPoint.zero
    @IBOutlet weak var ticketView: TicketTransitionView!
    @IBOutlet private weak var ticketContainer: UIView!
    @IBOutlet private weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topLabel: UILabel!
    private let SnapAnimationDuration = 0.4
    private let MaxTopOverscroll: CGFloat = 200.0
    
    class func loadFromStoryboard(_ viewModel: TicketDetailsViewModel) -> TicketDetailsViewController {
        let viewController = loadViewControllerFromStoryboard() as TicketDetailsViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupTicketInfo()
        setupActions()
        viewModel.editViewModel
            .subscribe(onNext: { viewModel in
                self.showEditViewController(with: viewModel)
            })
            .disposed(by: disposeBag)
    }
    
    func animateAppearance(completion: ((Bool) -> Void)? = nil) {
        view.layoutIfNeeded()
        view.backgroundColor = UIColor.clear
        let finalFrame = ticketView.convert(ticketView.bounds, to: view)
        let offset = initialFrame.minY - finalFrame.minY
        viewTopConstraint.constant = offset
        view.layoutIfNeeded()
        ticketView.set(state: .expanded, animated: true)
        viewTopConstraint.constant = 0
        topLabel.alpha = 0
        UIView.animate(withDuration: SnapAnimationDuration, animations: {
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.tableBackgroundColor
            self.topLabel.alpha = 1
        }, completion: { finished in
            completion?(finished)
        })
    }
    
    func animateDisappearance(endFrame: CGRect, completion: ((Bool) -> Void)? = nil) {
        let finalFrame = ticketContainer.convert(endFrame, from: view)
        UIView.animate(withDuration: SnapAnimationDuration / 3) {
            self.topLabel.alpha = 0
        }
        UIView.animate(withDuration: SnapAnimationDuration, animations: {
            self.ticketView.frame = finalFrame
            self.view.backgroundColor = UIColor.clear
        }, completion: { finished in
            completion?(finished)
        })
    }
    
    func animateExpand() {
        ticketView.set(state: .expanded, animated: true)
        UIView.animate(withDuration: ticketView.AnimationDuration) {
            self.topLabel.text = NSLocalizedString("Cмахните чтобы закрыть", comment: "")
            self.topLabel.transform = .identity
        }
    }
    
    func animateCollapse() {
        ticketView.set(state: .collapsed, animated: true)
        UIView.animate(withDuration: ticketView.AnimationDuration) {
            self.topLabel.text = NSLocalizedString("Закрыть", comment: "")
            self.topLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
    }
    
    
    private func shareButtonTap() {
        let controller = UIActivityViewController(activityItems: [viewModel.shareMessage], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func viewDragged(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            startPoint = sender.location(in: view)
        case .changed:
            let location = sender.location(in: view)
            var yDiff = location.y - startPoint.y
            if yDiff < 0 {
                yDiff = -MaxTopOverscroll * (1 - MaxTopOverscroll / (MaxTopOverscroll-yDiff))
            }
            viewTopConstraint.constant = yDiff
            if yDiff > 120.0 && !shouldGoBack {
                shouldGoBack = true
                animateCollapse()
            } else if yDiff < 80.0 && shouldGoBack {
                shouldGoBack = false
                animateExpand()
            }
        case .ended, .failed:
            if shouldGoBack {
                navigationController?.popViewController(animated: true)
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
        let alert = UIAlertController(title: NSLocalizedString("Удалить Билет?", comment: ""),
                                      message: NSLocalizedString("Вы действительно хотите удалить билет?", comment: ""),
                                      preferredStyle: .alert)
        let yesAction = UIAlertAction(title: NSLocalizedString("Да", comment: ""),
                                      style: .destructive) { _ in
            self.viewModel.delete()
            self.navigationController?.popViewController(animated: true)
        }
        let noAction = UIAlertAction(title: NSLocalizedString("Нет", comment: ""),
                                     style: .cancel,
                                     handler: nil)
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
        
        ticketView.expandedView.shareAction
            .subscribe(onNext: { _ in
                self.shareButtonTap()
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
