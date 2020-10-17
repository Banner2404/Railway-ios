//
//  DateInputView.swift
//  Railway
//
//  Created by Евгений Соболь on 9/1/20.
//  Copyright © 2020 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DateInputView: UIView {

    let datePicker = UIDatePicker()
    let textField = UITextField()
    var isValid = true {
        didSet {
            updateColors()
        }
    }
    private let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

// MARK: - Private
private extension DateInputView {

    func setup() {
        if #available(iOS 14.0, *) {
            setupDatePicker()
        } else {
            setupTextField()
        }
        updateColors()
    }

    func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        addSubview(datePicker)
        datePicker.attachToFrame(of: self)
        datePicker.datePickerMode = .dateAndTime
    }

    func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        textField.attachToFrame(of: self)
        textField.inputView = datePicker

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .dateAndTime

        datePicker.rx.value
            .map { DateFormatters.shortDateAndTime.string(from: $0) }
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
    }

    func updateColors() {
        let color = isValid ? UIColor.text : UIColor.red
        datePicker.tintColor = color
        textField.textColor = color
    }
}

extension Reactive where Base: DateInputView {

    var isValid: Binder<Bool> {
        return Binder(self.base) { view, value in
            view.isValid = value
        }
    }
}
