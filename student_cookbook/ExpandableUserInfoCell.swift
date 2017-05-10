//
//  ExpandableUserInfoCell.swift
//  student_cookbook
//
//  Created by Jade Redworth on 10/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit

class ExpandableUserInfoCell: UITableViewCell {
    
    @IBOutlet weak var buttonInfo: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    class var expandedHeight: CGFloat { get { return 200}}
    class var defaultHeight: CGFloat { get { return 44}}
    
    var frameAdded = false

    func checkHeight(){
        infoView.isHidden = (frame.size.height < ExpandableUserInfoCell.expandedHeight)
    }
    
    func watchFrameChanges() {
        if(!frameAdded){
            addObserver(self, forKeyPath: "frame", options: .new, context: nil)
            frameAdded = true
        }
    }
    
    func ignoreFrameChanges(){
        if(frameAdded){
            removeObserver(self, forKeyPath: "frame")
            frameAdded = false
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
    
    deinit {
        ignoreFrameChanges()
    }
}
