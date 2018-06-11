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
    
    override func viewDidLoad() {
        for viewModel in viewModel.places.value {
            addPlaceView(for: viewModel)
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return stackView.arrangedSubviews.first?.becomeFirstResponder() ?? false
    }
    
    @IBAction func addPlaceTap(_ sender: Any) {
        
        let placeViewModel = AddPlaceViewModel()
        viewModel.places.value.append(placeViewModel)
        addPlaceView(for: placeViewModel)
        
    }
    
    func addPlaceView(for placeViewModel: AddPlaceViewModel) {
        let view = AddPlaceView(frame: .zero)
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
}

//MARK: - AddPlaceViewDelegate
extension AddPlaceViewController: AddPlaceViewDelegate {
    
    func addPlaceViewDidTapRemove(_ view: AddPlaceView) {
        guard let index = stackView.arrangedSubviews.index(of: view) else { return }
        stackView.removeArrangedSubview(view)
        view.removeFromSuperview()
        viewModel.places.value.remove(at: index)
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
