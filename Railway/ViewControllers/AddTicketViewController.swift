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
    private var placesViewController: AddPlaceViewController!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var sourceTextField: UITextField!
    @IBOutlet private weak var destinationTextField: UITextField!
    @IBOutlet private weak var departureTimeTextField: UITextField!
    @IBOutlet private weak var arrivalTimeTextField: UITextField!
    @IBOutlet private weak var placesView: UIView!
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var notesTextView: UITextView!
    
    class func loadFromStoryboard(_ viewModel: AddTicketViewModel) -> AddTicketViewController {
        let viewController = loadViewControllerFromStoryboard() as AddTicketViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacesView()
        setupDatePickers()
        setupDefaultInfo()

        sourceTextField.rx.text
            .map{ $0 ?? "" }
            .map{ $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .bind(to: viewModel.sourceName)
            .disposed(by: disposeBag)
        destinationTextField.rx.text
            .map{ $0 ?? "" }
            .map{ $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .bind(to: viewModel.destinationName)
            .disposed(by: disposeBag)
        
        departureDatePicker.rx.value
            .map { DateFormatters.shortDateAndTime.string(from: $0) }
            .bind(to: departureTimeTextField.rx.text)
            .disposed(by: disposeBag)
        departureDatePicker.rx.value
            .bind(to: viewModel.departureDate)
            .disposed(by: disposeBag)
        
        arrivalDatePicker.rx.value
            .map { DateFormatters.shortDateAndTime.string(from: $0) }
            .bind(to: arrivalTimeTextField.rx.text)
            .disposed(by: disposeBag)
        arrivalDatePicker.rx.value
            .bind(to: viewModel.arrivalDate)
            .disposed(by: disposeBag)
        
        notesTextView.rx.value
            .map { $0 ?? "" }
            .bind(to: viewModel.notes)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func saveButtonTap(_ sender: Any) {
        viewModel.save()
        navigationController?.popViewController(animated: true)
    }
    
    private func setupDefaultInfo() {
        sourceTextField.text = viewModel.sourceName.value
        destinationTextField.text = viewModel.destinationName.value
        departureDatePicker.date = viewModel.departureDate.value
        arrivalDatePicker.date = viewModel.arrivalDate.value
        notesTextView.text = viewModel.notes.value
    }
    
    private func createDatePicker() -> UIDatePicker {
        let picker = UIDatePicker(frame: .zero)
        picker.datePickerMode = .dateAndTime
        return picker
    }
    
    private func setupDatePickers() {
        departureDatePicker = createDatePicker()
        departureTimeTextField.inputView = departureDatePicker
        
        arrivalDatePicker = createDatePicker()
        arrivalTimeTextField.inputView = arrivalDatePicker
    }
    
    private func setupPlacesView() {
        placesViewController = AddPlaceViewController.loadFromStoryboard(viewModel: viewModel)
        placesView.addSubview(placesViewController.view)
        addChildViewController(placesViewController)
        placesViewController.didMove(toParentViewController: self)
        placesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        placesView.leftAnchor.constraint(equalTo: placesViewController.view.leftAnchor).isActive = true
        placesView.rightAnchor.constraint(equalTo: placesViewController.view.rightAnchor).isActive = true
        placesView.topAnchor.constraint(equalTo: placesViewController.view.topAnchor).isActive = true
        placesView.bottomAnchor.constraint(equalTo: placesViewController.view.bottomAnchor).isActive = true
    }
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
    }
    
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

}

//MARK: - UITextFieldDelegate
extension AddTicketViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFields = [sourceTextField, destinationTextField, departureTimeTextField, arrivalTimeTextField]
        if let index = textFields.firstIndex(of: textField), index < textFields.endIndex - 1 {
            textFields[index + 1]?.becomeFirstResponder()
        } else {
            _ = placesViewController.becomeFirstResponder()
        }
        return false
    }
}
