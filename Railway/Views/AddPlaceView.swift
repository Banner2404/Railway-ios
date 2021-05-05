//
//  AddPlaceView.swift
//  Railway
//
//  Created by Евгений Соболь on 5/28/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

protocol AddPlaceViewDelegate: AnyObject {
    func addPlaceViewShouldReturn(_ view: AddPlaceView) -> Bool
    func addPlaceViewDidTapRemove(_ view: AddPlaceView)
}

class AddPlaceView: UIView {
    
    @IBOutlet weak var carriageImageView: UIImageView!
    @IBOutlet weak var seatImageView: UIImageView!
    @IBOutlet weak var carriageTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    weak var delegate: AddPlaceViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return carriageTextField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return placeTextField.resignFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    @IBAction private func buttonTap(_ sender: Any) {
        delegate?.addPlaceViewDidTapRemove(self)
    }
}

//MARK: - Private
private extension AddPlaceView {
    
    func setup() {
        let view = loadFromNib()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        carriageImageView.tintColor = .navigationBarTint
        seatImageView.tintColor = .navigationBarTint
        carriageTextField.textColor = .text
        placeTextField.textColor = .text
    }
}

//MARK: - UITextFieldDelegate
extension AddPlaceView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === carriageTextField {
            placeTextField.becomeFirstResponder()
            return false
        }
        return delegate?.addPlaceViewShouldReturn(self) ?? false
    }
}
