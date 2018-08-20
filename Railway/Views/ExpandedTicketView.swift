//
//  ExpandedTicketView.swift
//  Railway
//
//  Created by Евгений Соболь on 7/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ExpandedTicketView: UIView {
    
    var places: [PlaceView] = [] {
        didSet {
            updatePlaces()
        }
    }
    
    var shareAction: ControlEvent<Void> {
        return shareButton.rx.tap
    }
    
    @IBOutlet weak var stationsLabel: UILabel!
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placesView: UIStackView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
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

//MARK: - Private
private extension ExpandedTicketView {
    
    func updatePlaces() {
        for view in placesView.arrangedSubviews {
            placesView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        for place in places {
            placesView.addArrangedSubview(place)
        }
    }
    
    func setup() {
        let view = loadFromNib()
        view.translatesAutoresizingMaskIntoConstraints  = false
        addSubview(view)
        view.attachToFrame(of: self)
    }
}
