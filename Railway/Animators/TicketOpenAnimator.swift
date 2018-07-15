//
//  TicketOpenAnimator.swift
//  Railway
//
//  Created by Евгений Соболь on 7/2/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class TicketOpenAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var initialFrame: CGRect = .zero
    var initialView: UIView?
    
    let AnimationDuration: TimeInterval = 2.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        let detailsViewController = transitionContext.viewController(forKey: .to) as! TicketDetailsViewController
        let finalView = createFinalCardView(from: detailsViewController)
        let ticketView = createTransitionView(finalView: finalView)
        let backgroundView = createBackgroundView()
        let placeholderView = createPlaceholderView()
        
        containerView.addSubview(placeholderView)
        containerView.addSubview(backgroundView)
        containerView.addSubview(ticketView)
        containerView.addSubview(toView)

        toView.frame = fromView.frame
        backgroundView.frame = fromView.frame
        placeholderView.frame = initialFrame
        toView.alpha = 0
        
        UIView.animateKeyframes(withDuration: AnimationDuration,
                                delay: 0.0,
                                options: [],
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 0.6,
                                                       animations: {
                                                        self.initialView?.alpha = 0
                                                        finalView.alpha = 1
                                                        backgroundView.alpha = 1
                                                        ticketView.frame.origin = self.expandOrigin(forFinalSize: detailsViewController.ticketCardViewFrame.size)
                                                        ticketView.frame.size = detailsViewController.ticketCardViewFrame.size }
                                    )
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 0.6,
                                                       relativeDuration: 0.4, animations: {
                                                        ticketView.frame = detailsViewController.ticketCardViewFrame }
                                    )},
                                completion: { _ in
                                    toView.alpha = 1
                                    transitionContext.completeTransition(true) }
        )
    }
    
    func expandOrigin(forFinalSize size: CGSize) -> CGPoint {
        let difference = size.height - initialFrame.size.height
        let expandSize = difference / 2
        return CGPoint(x: initialFrame.origin.x, y: initialFrame.origin.y - expandSize)
    }
    
    func createPlaceholderView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.tableBackgroundColor
        return view
    }
    
    func createTransitionView(finalView: UIView) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.frame = initialFrame
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        
        if let initialView = self.initialView {
            view.addSubview(initialView)
            initialView.frame = view.bounds
        }
        view.addSubview(finalView)
        finalView.alpha = 0
        return view
    }
    
    func createBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.tableBackgroundColor
        view.alpha = 0
        return view
    }

    
    func createFinalCardView(from viewController: TicketDetailsViewController) -> UIView {
        viewController.view.layoutIfNeeded()
        let cardView = viewController.ticketCardView!
        UIGraphicsBeginImageContextWithOptions(cardView.bounds.size, false, 0.0)
        cardView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImageView(image: image)
    }
}
