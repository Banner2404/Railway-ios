//
//  AddTicketViewController.swift
//  Railway
//
//  Created by Евгений Соболь on 5/28/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddTicketViewController: ViewController {
    
    private var viewModel: AddTicketViewModel!
    private let disposeBag = DisposeBag()
    private var departureDatePicker: UIDatePicker!
    private var arrivalDatePicker: UIDatePicker!
    @IBOutlet private weak var sourceTextField: UITextField!
    @IBOutlet private weak var destinationTextField: UITextField!
    @IBOutlet private weak var departureTimeTextField: UITextField!
    @IBOutlet private weak var arrivalTimeTextField: UITextField!
    @IBOutlet private weak var placesView: UIView!
    
    class func loadFromStoryboard(_ viewModel: AddTicketViewModel) -> AddTicketViewController {
        let viewController = loadViewControllerFromStoryboard() as AddTicketViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacesView()
        setupDatePickers()
        sourceTextField.rx.text
            .map{ $0 ?? "" }
            .bind(to: viewModel.sourceName)
            .disposed(by: disposeBag)
        destinationTextField.rx.text
            .map{ $0 ?? "" }
            .bind(to: viewModel.destinationName)
            .disposed(by: disposeBag)
    }
    
    @IBAction func saveButtonTap(_ sender: Any) {
        print(viewModel.places.map { $0.carriage.value + " " + $0.seat.value })
    }
    
    private func createDatePicker() -> UIDatePicker {
        let picker = UIDatePicker(frame: .zero)
        picker.datePickerMode = .dateAndTime
        return picker
    }
    
    private func setupDatePickers() {
        departureDatePicker = createDatePicker()
        departureDatePicker.rx.value
            .map { DateFormatters.shortDateAndTime.string(from: $0) }
            .bind(to: departureTimeTextField.rx.text)
            .disposed(by: disposeBag)
        departureDatePicker.rx.value
            .bind(to: viewModel.departureDate)
            .disposed(by: disposeBag)
        departureTimeTextField.inputView = departureDatePicker
        
        arrivalDatePicker = createDatePicker()
        arrivalDatePicker.rx.value
            .map { DateFormatters.shortDateAndTime.string(from: $0) }
            .bind(to: arrivalTimeTextField.rx.text)
            .disposed(by: disposeBag)
        arrivalDatePicker.rx.value
            .bind(to: viewModel.arrivalDate)
            .disposed(by: disposeBag)
        arrivalTimeTextField.inputView = arrivalDatePicker
    }
    
    private func setupPlacesView() {
        let placesViewController = AddPlaceViewController.loadFromStoryboard(viewModel: viewModel)
        placesView.addSubview(placesViewController.view)
        addChildViewController(placesViewController)
        placesViewController.didMove(toParentViewController: self)
        placesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        placesView.leftAnchor.constraint(equalTo: placesViewController.view.leftAnchor).isActive = true
        placesView.rightAnchor.constraint(equalTo: placesViewController.view.rightAnchor).isActive = true
        placesView.topAnchor.constraint(equalTo: placesViewController.view.topAnchor).isActive = true
        placesView.bottomAnchor.constraint(equalTo: placesViewController.view.bottomAnchor).isActive = true
    }
}
