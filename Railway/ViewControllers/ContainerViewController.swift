//
//  ContainerViewController.swift
//  Spinn.coffee
//
//  Created by Insoft on 5/16/17.
//  Copyright © 2017 Insoft. All rights reserved.
//

import UIKit

protocol ContainerViewController {
    
    func move(from fromViewController: UIViewController, to toViewController: UIViewController, inContainerView containerView: UIView)
    func show(_ viewController: UIViewController, inContainerView containerView: UIView)
    func removeViewControllerFromContainerView(_ viewController: UIViewController?)
    func replaceCurrentViewController(with newViewController: UIViewController, in containerView: UIView)
}

extension ContainerViewController where Self: UIViewController {
    
    func move(from fromViewController: UIViewController, to toViewController: UIViewController, inContainerView containerView: UIView) {
        addChildViewController(toViewController)
        toViewController.didMove(toParentViewController: self)
        
        let fromView = fromViewController.view!
        let toView = toViewController.view!
        
        toView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(toView)
        
        toView.alpha = 0
        
        containerView.topAnchor.constraint(equalTo: toView.topAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: toView.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: toView.bottomAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: toView.rightAnchor).isActive = true
        
        fromViewController.willMove(toParentViewController: nil)
        fromViewController.removeFromParentViewController()
        UIView.animate(withDuration: 0.3, animations: {
            fromView.alpha = 0
            toView.alpha = 1
            
        }, completion: { (finished) in
            if finished {
                fromView.removeFromSuperview()
            }
        })
    }
    
    func show(_ viewController: UIViewController, inContainerView containerView: UIView) {
        addChildViewController(viewController)
        let childView = viewController.view!
        
        containerView.addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.topAnchor.constraint(equalTo: childView.topAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: childView.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: childView.rightAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: childView.bottomAnchor).isActive = true
        
        viewController.didMove(toParentViewController: self)
    }
    
    func removeViewControllerFromContainerView(_ viewController: UIViewController?) {
        
        viewController?.willMove(toParentViewController: nil)
        viewController?.view.removeFromSuperview()
        viewController?.removeFromParentViewController()
        
    }
    
    
    func replaceCurrentViewController(with newViewController: UIViewController, in containerView: UIView) {
        if let viewController = childViewControllers.first {
            move(from: viewController, to: newViewController, inContainerView: containerView)
        } else {
            show(newViewController, inContainerView: containerView)
        }
    }
}
