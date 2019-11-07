//
//  CollapsedTicketView.swift
//  Railway
//
//  Created by Евгений Соболь on 7/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class CollapsedTicketView: UIView {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var stationsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(with viewModel: TicketViewModel) {
        stationsLabel.text = viewModel.routeText
        dateLabel.text = viewModel.dateText
    }
}

//MARK: - Private
private extension CollapsedTicketView {
    
    func setup() {
        let view = loadFromNib()
        view.translatesAutoresizingMaskIntoConstraints  = false
        addSubview(view)
        view.attachToFrame(of: self)
        self.backgroundColor = UIColor.clear
        mainView.backgroundColor = .cardBackground
        stationsLabel.textColor = .text
        dateLabel.textColor = .text
    }
}
