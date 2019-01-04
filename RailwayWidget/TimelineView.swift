//
//  TimelineView.swift
//  RailwayWidget
//
//  Created by Евгений Соболь on 1/3/19.
//  Copyright © 2019 Евгений Соболь. All rights reserved.
//

import UIKit

class TimelineView: UIView {

    var value: CGFloat = 0.9 {
        didSet {
            setNeedsDisplay()
        }
    }
    var color: UIColor = UIColor.tableBackgroundColor
    var textColor: UIColor = UIColor.textColor
    var leftText: String = "10:20" {
        didSet {
            setNeedsDisplay()
        }
    }
    var centerText: String = "10 m left" {
        didSet {
            setNeedsDisplay()
        }
    }
    var rightText: String = "12:20" {
        didSet {
            setNeedsDisplay()
        }
    }
    var font: UIFont = UIFont.systemFont(ofSize: 16.0)

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: font.pointSize + capSize * 4)
    }

    private var capSize: CGFloat = 4.0
    private var lineWidth: CGFloat = 3.0

    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawLine(rect, context: context, color: color.withAlphaComponent(0.7), from: 0.0, to: value)
        drawLine(rect, context: context, color: color.withAlphaComponent(0.4), from: value, to: 1.0)
        drawCap(rect, context: context)
        drawLabels(rect)
    }

    private func drawLine(_ rect: CGRect, context: CGContext, color: UIColor, from: CGFloat, to: CGFloat) {
        let fullLineWidth = drawableLineWidth(for: rect)
        let x = capSize + fullLineWidth * from
        let y = rect.height - capSize * 2 - lineWidth / 2
        let width = fullLineWidth * (to - from)
        let height = lineWidth

        let path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: width, height: height), cornerRadius: height / 2)

        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
    }

    private func drawCap(_ rect: CGRect, context: CGContext) {
        let fullLineWidth = drawableLineWidth(for: rect)
        let x = capSize + fullLineWidth * value
        let y = rect.height - capSize * 2

        context.setFillColor(color.cgColor)
        context.addArc(center: CGPoint(x: x, y: y), radius: capSize, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context.setShadow(offset: .zero, blur: capSize * 3 / 2)
        context.fillPath()
        context.setShadow(offset: .zero, blur: 0.0)
    }

    private func drawableLineWidth(for rect: CGRect) -> CGFloat {
        return rect.width - capSize * 2
    }

    private func drawLabels(_ rect: CGRect) {
        draw(text: leftText, alignment: .left, rect: rect)
        draw(text: centerText, alignment: .center, rect: rect)
        draw(text: rightText, alignment: .right, rect: rect)
    }

    private func draw(text: String, alignment: NSTextAlignment, rect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment

        let string = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: textColor])

        string.draw(in: CGRect(x: capSize, y: (rect.height / 2) - capSize - font.pointSize, width: rect.width - capSize * 2, height: rect.height))
    }

}
