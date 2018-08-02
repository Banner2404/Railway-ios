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
    var initialViewModel: TicketViewModel!
    var finalViewModel: TicketDetailsViewModel!
    var transition: Transition = .push
    var animatePop = true
    
    let AnimationDuration: TimeInterval = 0.4
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transition {
        case .push:
            animatePushTransition(using: transitionContext)
        case .pop:
            animatePopTransition(using: transitionContext)
        }
    }
    
    func animatePushTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let toVC = transitionContext.viewController(forKey: .to) as! TicketDetailsViewController
        container.addSubview(toView)
        toVC.initialFrame = initialFrame
        toVC.animator = self
        toVC.animateAppearance { finished in
            transitionContext.completeTransition(finished)
        }
        animatePop = true
    }
    
    func animatePopTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        let fromVC = transitionContext.viewController(forKey: .from) as! TicketDetailsViewController
        let toVC = transitionContext.viewController(forKey: .to) as! TicketListViewController
        if animatePop {
            container.insertSubview(toView, belowSubview: fromView)
            toVC.animatePop()
            fromVC.animateDisappearance { finished in
                toVC.completePop()
                transitionContext.completeTransition(finished)
            }
        } else {
            UIView.transition(from: fromView,
                              to: toView,
                              duration: AnimationDuration,
                              options: [.transitionCrossDissolve]) { finished in
                                transitionContext.completeTransition(finished)
            }
        }
        
    }
    
    func expandOrigin(forFinalSize size: CGSize) -> CGPoint {
        let difference = size.height - initialFrame.size.height
        let expandSize = difference / 2
        return CGPoint(x: initialFrame.origin.x, y: initialFrame.origin.y - expandSize)
    }
    
    enum Transition {
        case push
        case pop
    }
}
