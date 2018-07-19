//
//  TicketView.swift
//  Railway
//
//  Created by Евгений Соболь on 7/15/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit

class TicketTransitionView: UIView {
    
    var collapsedView: CollapsedTicketView!
    var expandedView: ExpandedTicketView!
    private(set) var state = State.collapsed
    private var collapsedBottomConstraint: NSLayoutConstraint!
    private var expandedBottomConstraint: NSLayoutConstraint!
    private let AnimationDuration = 0.3
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func set(state: State, animated: Bool) {
        if self.state == state { return }
        self.state = state
        updateState(animated: animated)
    }
    
    enum State {
        case expanded
        case collapsed
    }
}

//MARK: - Private
private extension TicketTransitionView {
    
    func setupCollapsedView() {
        collapsedView = CollapsedTicketView()
        collapsedView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(collapsedView)
        collapsedBottomConstraint = self.bottomAnchor.constraint(equalTo: collapsedView.bottomAnchor)
        NSLayoutConstraint.activate([
            collapsedView.heightAnchor.constraint(equalToConstant: 80.0),
            topAnchor.constraint(equalTo: collapsedView.topAnchor),
            leftAnchor.constraint(equalTo: collapsedView.leftAnchor),
            rightAnchor.constraint(equalTo: collapsedView.rightAnchor)
            ])
    }
    
    func setupExpandedView() {
        expandedView = ExpandedTicketView()
        expandedView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(expandedView)
        expandedBottomConstraint = self.bottomAnchor.constraint(equalTo: expandedView.bottomAnchor)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: expandedView.topAnchor),
            leftAnchor.constraint(equalTo: expandedView.leftAnchor),
            rightAnchor.constraint(equalTo: expandedView.rightAnchor)
            ])
    }
    
    func updateState(animated: Bool) {
        switch state {
        case .collapsed:
            expand(animated: animated)
        case .expanded:
            collapse(animated: animated)
        }
    }
    
    func expand(animated: Bool) {
        expandedBottomConstraint.isActive = false
        collapsedBottomConstraint.isActive = true
        collapsedView.isHidden = false
        if animated {
            UIView.animate(withDuration: AnimationDuration, animations: {
                self.expandedView.alpha = 0.0
                self.collapsedView.alpha = 1.0
                self.superview?.layoutIfNeeded()
            }, completion: { finished in
                if finished {
                    self.expandedView.isHidden = true
                }
            })
        } else {
            expandedView.alpha = 0.0
            collapsedView.alpha = 1.0
            expandedView.isHidden = true
        }
    }
    
    func collapse(animated: Bool) {
        collapsedBottomConstraint.isActive = false
        expandedBottomConstraint.isActive = true
        expandedView.isHidden = false
        if animated {
            UIView.animate(withDuration: AnimationDuration, animations: {
                self.expandedView.alpha = 1.0
                self.collapsedView.alpha = 0.0
                self.superview?.layoutIfNeeded()
            }, completion: { finished in
                if finished {
                    self.collapsedView.isHidden = true
                }
            })
        } else {
            expandedView.alpha = 1.0
            collapsedView.alpha = 0.0
            collapsedView.isHidden = true
        }
    }
    
    func setup() {
        setupCollapsedView()
        setupExpandedView()
        updateState(animated: false)
        self.clipsToBounds = true
    }
}
