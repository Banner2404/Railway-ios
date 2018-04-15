//
//  ViewController.swift
//  Railway
//
//  Created by Евгений Соболь on 4/3/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

protocol ViewControllerProtocol: class {
    static func loadFromStoryboard() -> Self
}

extension ViewControllerProtocol where Self: UIViewController {
        
    static func loadFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
}

class ViewController: UIViewController, ViewControllerProtocol {
    
    @available(iOS, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Init is unavailable")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @available(iOS, unavailable)
    init() {
        fatalError("Init is unavailable")
    }

}
