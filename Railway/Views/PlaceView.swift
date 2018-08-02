//
//  PlaceView.swift
//  Railway
//
//  Created by Евгений Соболь on 4/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class PlaceView: UIView {
    
    @IBOutlet weak var carriageLabel: UILabel!
    @IBOutlet weak var seatLabel: UILabel!
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: 40)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

//MARK: - Private
private extension PlaceView {
    
    func setup() {
        let view = loadFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        self.backgroundColor = .clear
    }
}
