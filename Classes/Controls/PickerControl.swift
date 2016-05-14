//
//  PickerControl.swift
//  ProtonomeAudioKitControls
//
//  Created by Daniel Clelland on 5/12/15.
//  Copyright © 2015 Daniel Clelland. All rights reserved.
//

import UIKit

@IBDesignable public class PickerControl: ParameterControl {
    
    // MARK: - Properties
    
    @IBInspectable public var gridColumns: UInt = 0 {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var gridRows: UInt = 0 {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var gutter: CGFloat = 2.0 {
        didSet {
            setNeedsUpdateConstraints()
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    // MARK: - Views
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.userInteractionEnabled = false
        return view
    }()
    
    // MARK: - Overrides
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        for index in 0..<gridCells {
            containerView.addSubview(valueLabel(forIndex: index))
        }
    }
    
    override public func updateConstraints() {
        super.updateConstraints()
        
        addSubview(containerView)
        containerView.snp_updateConstraints { make in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(titleLabel.snp_top).offset(-gutter)
        }
    }
    
    // MARK: - Overrideables
    
    override func ratio(forLocation location: CGPoint) -> Float {
        let rect = containerView.frame
        
        let column = floor((Float(location.x.ilerp(min: rect.minX, max: rect.maxX)) * Float(gridColumns)).clamp(min: 0.0, max: Float(gridColumns - 1)))
        let row = floor((Float(location.y.ilerp(min: rect.minY, max: rect.maxY)) * Float(gridRows)).clamp(min: 0.0, max: Float(gridRows - 1)))
        
        let index = UInt((Float(row) * Float(gridColumns) + column).clamp(min: 0.0, max: Float(gridCells - 1)))
        
        return ratio(forIndex: index)
    }
    
    override func path(forRatio ratio: Float) -> UIBezierPath {
        let index = self.index(forRatio: ratio)
        return UIBezierPath.init(roundedRect: cell(forIndex: index), cornerRadius: cornerRadius)
    }
    
    // MARK: - Private getters
    
    private var gridCells: UInt {
        if let steps = (scale as? SteppedParameterScale)?.values.count {
            return min(UInt(steps), gridColumns * gridRows)
        }
        
        return gridColumns * gridRows
    }
    
    private func index(forRatio ratio: Float) -> UInt {
        return UInt(round(ratio * Float(gridCells - 1)))
    }
    
    private func ratio(forIndex index: UInt) -> Float {
        return Float(index) / Float(gridCells - 1)
    }
    
    private func valueLabel(forIndex index: UInt) -> UILabel {
        let label = UILabel(frame: cell(forIndex: index))
        label.text = formatter.string(forValue: scale.value(forRatio: ratio(forIndex: index)))
        label.font = font
        label.textAlignment = .Center
        label.textColor = UIColor.protonome_blackColor()
        return label
    }
    
    private func cell(forIndex index: UInt) -> CGRect {
        let x = Int(index % gridColumns)
        let y = Int(index / gridColumns)
        
        return containerView.bounds.cell(atX: x, y: y, columns: gridColumns, rows: gridRows, gutter: gutter)
    }
    
}

// MARK: - Private extensions

private extension CGRect {
    
    func cell(atX x: Int, y: Int, columns: UInt, rows: UInt, gutter: CGFloat = 0.0) -> CGRect {
        let scale = UIScreen.mainScreen().scale
        
        let cellWidth = (width + gutter) / CGFloat(columns)
        let cellHeight = (height + gutter) / CGFloat(rows)
        
        let leftEdge = round((cellWidth * CGFloat(x) + minX) * scale) / scale
        let topEdge = round((cellHeight * CGFloat(y) + minY) * scale) / scale
        
        let rightEdge = round((cellWidth * CGFloat(x + 1) - gutter + minX) * scale) / scale
        let bottomEdge = round((cellHeight * CGFloat(y + 1) - gutter + minY) * scale) / scale
        
        return CGRectMake(leftEdge, topEdge, rightEdge - leftEdge, bottomEdge - topEdge)
    }
    
}
