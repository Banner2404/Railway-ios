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
    @IBOutlet private weak var notesTextView: UITextView!
    
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
        
        viewModel.notes
            .bind(to: notesTextView.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.places
            .subscribe(onNext: { places in
                for view in self.ticketsStackView.arrangedSubviews {
                    self.ticketsStackView.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
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
