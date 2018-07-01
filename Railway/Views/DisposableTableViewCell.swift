//
//  DisposableTableViewCell.swift
//  Railway
//
//  Created by Евгений Соболь on 7/1/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift

class DisposableTableViewCell: UITableViewCell {

    var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

}
