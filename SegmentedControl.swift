//
//  SegmentedControl.swift
//  student_cookbook
//
//  Created by Jade Redworth on 29/04/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit

@IBDesignable class SegmentedControl: UIControl {

    private var labels = [UILabel]()
    var thumbView = UIView()
    
    var items:[String] = ["Info", "Ingredients", "Steps"] {
        didSet {
            setUpLabels()
        }
    }
    
    var selectedIndex: Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    
    func setUpView() {
        layer.cornerRadius = frame.height/2
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        layer.backgroundColor = UIColor.clear.cgColor
        setUpLabels()
        insertSubview(thumbView, at: 0)
        
    }
    
    func setUpLabels() {
        for labels in labels {
            labels.removeFromSuperview()
        }
        
        labels.removeAll(keepingCapacity: true)
        for index in 1...items.count {
            let label = UILabel(frame: CGRect.zero)
            label.text = items[index - 1]
            label.textAlignment = .center
            label.textColor = UIColor(white: 0.5, alpha: 1.0)
            self.addSubview(label)
            labels.append(label)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init(coder : NSCoder) {
        super.init(coder: coder)!
        setUpView()
    }
    
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectedFrame = self.bounds
        let newWidth = selectedFrame.width / CGFloat(items.count)
        selectedFrame.size.width = newWidth
        thumbView.frame = selectedFrame
        thumbView.backgroundColor = UIColor.white
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
        
        let labelHeight = self.bounds.height
        let labelWidth = self.bounds.width / CGFloat(labels.count)
        
        for index in 0...labels.count - 1 {
            let label = labels[index]
            
            let xPosition = CGFloat(index) * labelWidth
            label.frame = CGRect(x: xPosition, y: 0, width: labelWidth, height: labelHeight)
        }
    }
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        var calculatedIndex: Int?
        
        for(index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        
        return false
    }
    
    func displayNewSelectedIndex(){
        let label = labels[selectedIndex]
        self.thumbView.frame = label.frame
    }
}
