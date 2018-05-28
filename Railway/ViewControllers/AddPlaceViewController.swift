//
//  AddPlaceViewController.swift
//  Railway
//
//  Created by Евгений Соболь on 5/28/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class AddPlaceViewController: ViewController {

    @IBOutlet private weak var stackView: UIStackView!
    
    class func loadFromStoryboard() -> AddPlaceViewController {
        let viewController = loadViewControllerFromStoryboard()  as AddPlaceViewController
        return viewController
    }
    
    @IBAction func addPlaceTap(_ sender: Any) {
        let view = AddPlaceView(frame: .zero)
        view.delegate = self
        let count = stackView.arrangedSubviews.count
        stackView.insertArrangedSubview(view, at: count - 1)
    }
}

//MARK: - AddPlaceViewDelegate
extension AddPlaceViewController: AddPlaceViewDelegate {
    
    func addPlaceViewDidTapRemove(_ view: AddPlaceView) {
        stackView.removeArrangedSubview(view)
        view.removeFromSuperview()
    }
}
