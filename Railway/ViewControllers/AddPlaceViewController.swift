//
//  AddPlaceViewController.swift
//  Railway
//
//  Created by Евгений Соболь on 5/28/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddPlaceViewController: ViewController {

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var addPlaceLabel: UILabel!
    private var viewModel: AddTicketViewModel!
    private let disposeBag = DisposeBag()
    
    class func loadFromStoryboard(viewModel: AddTicketViewModel) -> AddPlaceViewController {
        let viewController = loadViewControllerFromStoryboard()  as AddPlaceViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlaceLabel.textColor = .text
        setupDefaultInfo()
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return stackView.arrangedSubviews.first?.becomeFirstResponder() ?? false
    }
    
    @IBAction func addPlaceTap(_ sender: Any) {
        let placeViewModel = AddPlaceViewModel(place: nil)
        var value = viewModel.places.value
        value.append(placeViewModel)
        viewModel.places.accept(value)
        addPlaceView(for: placeViewModel)
        
    }
    
    func addPlaceView(for placeViewModel: AddPlaceViewModel) {
        let view = AddPlaceView(frame: .zero)
        let carriage = placeViewModel.carriage.value
        view.carriageTextField.text = carriage == 0 ? "" : String(carriage)
        view.placeTextField.text = placeViewModel.seat.value
        view.delegate = self
        let count = stackView.arrangedSubviews.count
        stackView.insertArrangedSubview(view, at: count - 1)
        view.carriageTextField.rx.text
            .map { Int($0 ?? "") ?? 0 }
            .bind(to: placeViewModel.carriage)
            .disposed(by: disposeBag)
        view.placeTextField.rx.text
            .map { $0 ?? "" }
            .bind(to: placeViewModel.seat)
            .disposed(by: disposeBag)
    }
    
    private func setupDefaultInfo() {
        for viewModel in viewModel.places.value {
            addPlaceView(for: viewModel)
        }
    }
}

//MARK: - AddPlaceViewDelegate
extension AddPlaceViewController: AddPlaceViewDelegate {
    
    func addPlaceViewDidTapRemove(_ view: AddPlaceView) {
        guard let index = stackView.arrangedSubviews.firstIndex(of: view) else { return }
        stackView.removeArrangedSubview(view)
        view.removeFromSuperview()
        var value = viewModel.places.value
        value.remove(at: index)
        viewModel.places.accept(value)
    }
    
    func addPlaceViewShouldReturn(_ view: AddPlaceView) -> Bool {
        let views = stackView.arrangedSubviews.filter { $0 is AddPlaceView }
        if let index = views.firstIndex(of: view), index < views.endIndex - 1 {
            views[index + 1].becomeFirstResponder()
        } else {
            _ = view.resignFirstResponder()
        }
        return false
    }
}
