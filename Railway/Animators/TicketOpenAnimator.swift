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
    
    let AnimationDuration: TimeInterval = 2.0
    
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
    }
    
    func animatePopTransition(using transitionContext: UIViewControllerContextTransitioning) {
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
