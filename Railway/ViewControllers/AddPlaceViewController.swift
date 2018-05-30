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
    private var viewModel: AddTicketViewModel!
    private let disposeBag = DisposeBag()
    
    class func loadFromStoryboard(viewModel: AddTicketViewModel) -> AddPlaceViewController {
        let viewController = loadViewControllerFromStoryboard()  as AddPlaceViewController
        viewController.viewModel = viewModel
        return viewController
    }
    
    @IBAction func addPlaceTap(_ sender: Any) {
        let view = AddPlaceView(frame: .zero)
        view.delegate = self
        let count = stackView.arrangedSubviews.count
        stackView.insertArrangedSubview(view, at: count - 1)
        
        let placeViewModel = AddPlaceViewModel()
        view.carriageTextField.rx.text
            .map { $0 ?? "" }
            .bind(to: placeViewModel.carriage)
            .disposed(by: disposeBag)
        view.placeTextField.rx.text
            .map { $0 ?? "" }
            .bind(to: placeViewModel.seat)
            .disposed(by: disposeBag)
        viewModel.places.append(placeViewModel)
    }
}

//MARK: - AddPlaceViewDelegate
extension AddPlaceViewController: AddPlaceViewDelegate {
    
    func addPlaceViewDidTapRemove(_ view: AddPlaceView) {
        stackView.removeArrangedSubview(view)
        view.removeFromSuperview()
        viewModel.places.removeLast()
    }
}
