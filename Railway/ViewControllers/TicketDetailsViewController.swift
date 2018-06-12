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

    private let disposeBag = DisposeBag()
    private var viewModel: TicketDetailsViewModel!
    @IBOutlet private weak var stationsLabel: UILabel!
    @IBOutlet private weak var departureLabel: UILabel!
    @IBOutlet private weak var arrivalLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var ticketsStackView: UIStackView!
    
    class func loadFromStoryboard(_ viewModel: TicketDetailsViewModel) -> TicketDetailsViewController {
        let viewController = loadViewControllerFromStoryboard() as TicketDetailsViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTicketInfo()
        
        viewModel.editViewModel
            .subscribe(onNext: { viewModel in
                self.showEditViewController(with: viewModel)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func deleteTicketTap(_ sender: Any) {
        viewModel.delete()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonTap(_ sender: Any) {
        viewModel.edit()
    }
    
    private func showEditViewController(with viewModel: AddTicketViewModel) {
        let viewController = AddTicketViewController.loadFromStoryboard(viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func setupTicketInfo() {
        viewModel.stationsText
            .bind(to: stationsLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.departureTimeText
            .bind(to: departureLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.arrivalTimeText
            .bind(to: arrivalLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.dateText
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.places
            .subscribe(onNext: { places in
                for place in places {
                    let view = PlaceView()
                    view.carriageLabel.text = place.carriageText
                    view.seatLabel.text = place.seatText
                    self.ticketsStackView.addArrangedSubview(view)
                }
            })
            .disposed(by: disposeBag)
    }
}
