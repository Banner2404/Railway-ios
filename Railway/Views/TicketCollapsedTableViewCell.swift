//
//  TicketCollapsedTableViewCell.swift
//  Railway
//
//  Created by Евгений Соболь on 4/7/18.
//  Copyright © 2018 Евгений Соболь. All rights reserved.
//

import UIKit
import RxSwift

protocol TicketCollapsedTableViewCellDelegate: class {
    func ticketCollapsedTableViewCellDidShowDeleteButton(_ cell: TicketCollapsedTableViewCell)
    func ticketCollapsedTableViewCellDidTapDeleteButton(_ cell: TicketCollapsedTableViewCell)
}

class TicketCollapsedTableViewCell: HighlightableTableViewCell {

    weak var delegate: TicketCollapsedTableViewCellDelegate?
    
    @IBOutlet weak var ticketView: CollapsedTicketView!
    
    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var swipeContentView: UIView!
    private var panStart: CGPoint = CGPoint.zero
    private var lastTouch: CGPoint = CGPoint.zero
    private var swipeGestureRecognizer: UIPanGestureRecognizer!
    private let DeleteButtonWidth: CGFloat = 100.0
    private let MaxOvershootWidth: CGFloat = 200.0
    private let MaxUndershootWidth: CGFloat = 50.0
    private let SnapAnimationTiming: TimeInterval = 0.35
    private let VelocityThreshold: CGFloat = 10.0
    private let AnimationSpringDamping: CGFloat = 0.7
    private lazy var deleteButton: UIButton = createDeleteButton()
    private lazy var deleteButtonAnimator: UIViewPropertyAnimator = createButtonPropertyAnimator()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leadingConstraint.constant = 0.0
    }
    
    func hideDeleteButton() {
        hideButton(velocity: 0.0)
    }
    
    //MARK: - UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === self.swipeGestureRecognizer, let gr = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gr.velocity(in: self)
            return abs(velocity.x) > abs(velocity.y)
        } else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
    }

}

//MARK: - Private
private extension TicketCollapsedTableViewCell {
    
    func setup() {
        mainView.layer.cornerRadius = 10.0
        setupGestureRecognizer()
    }
    
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            panStart = recognizer.location(in: self)
            showDeleteButton()
            self.delegate?.ticketCollapsedTableViewCellDidShowDeleteButton(self)
        case .changed:
            let point = recognizer.location(in: self)
            var difference = lastTouch.x - point.x
            let currentOffset = leadingConstraint.constant
            let undershoot = max(currentOffset, 0.0)
            if undershoot > 0 {
                difference *= 1 - undershoot / MaxUndershootWidth
            }
            let overshoot = max(-currentOffset - DeleteButtonWidth, 0.0)
            if overshoot > 0 {
                difference *= 1 - overshoot / MaxOvershootWidth
            }
            let adjustedOffset = currentOffset - difference
            leadingConstraint.constant = adjustedOffset
            deleteButtonAnimator.isReversed = false
            deleteButtonAnimator.fractionComplete = abs(adjustedOffset) / DeleteButtonWidth
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: self).x / DeleteButtonWidth
            animateSwipeToFinalPosition(velocity: velocity)
        default:
            break
        }
        lastTouch = recognizer.location(in: self)
    }
    
    func createDeleteButton() -> UIButton {
        let button = UIButton()
        button.setTitle("X", for: .normal)
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 10.0
        button.addTarget(self, action: #selector(deleteButtonTap), for: .touchUpInside)
        return button
    }
    
    @objc func deleteButtonTap() {
        delegate?.ticketCollapsedTableViewCellDidTapDeleteButton(self)
    }
    
    func createButtonPropertyAnimator() -> UIViewPropertyAnimator {
        self.deleteButton.alpha = 0.0
        let animator = UIViewPropertyAnimator(duration: SnapAnimationTiming, curve: .easeIn) {
            self.deleteButton.alpha = 1.0
        }
        animator.scrubsLinearly = false
        animator.pausesOnCompletion = true
        animator.pauseAnimation()
        return animator
    }
    
    func showDeleteButton() {
        addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: self.mainView.topAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: self.mainView.bottomAnchor).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8.0).isActive = true
        let constraint = deleteButton.leftAnchor.constraint(equalTo: swipeContentView.rightAnchor)
        constraint.priority = UILayoutPriority(rawValue: 999.0)
        constraint.isActive = true
    }
    
    func animateSwipeToFinalPosition(velocity: CGFloat) {
        let offset = abs(min(leadingConstraint.constant, 0.0))
        if velocity > VelocityThreshold {
            hideButton(velocity: velocity)
        } else if velocity < -VelocityThreshold {
            showButton(velocity: velocity)
        } else if offset > DeleteButtonWidth / 2 {
            showButton(velocity: velocity)
        } else {
            hideButton(velocity: velocity)
        }
    }
    
    func hideButton(velocity: CGFloat) {
        leadingConstraint.constant = 0
        deleteButtonAnimator.isReversed = true
        deleteButtonAnimator.startAnimation()
        animateButton(velocity: velocity)
    }
    
    func showButton(velocity: CGFloat) {
        leadingConstraint.constant = -DeleteButtonWidth
        deleteButtonAnimator.isReversed = false
        deleteButtonAnimator.startAnimation()
        animateButton(velocity: velocity)
    }
    
    func animateButton(velocity: CGFloat) {
        UIView.animate(withDuration: SnapAnimationTiming,
                       delay: 0.0,
                       usingSpringWithDamping: AnimationSpringDamping,
                       initialSpringVelocity: velocity,
                       options: .curveEaseOut,
                       animations: {
                        self.layoutIfNeeded()
        })
    }
    
    func setupGestureRecognizer() {
        swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        swipeGestureRecognizer.delegate = self
        self.addGestureRecognizer(swipeGestureRecognizer)
    }
}
