//
//  Ratings.swift
//  student_cookbook
//
//  Created by Jade Redworth on 08/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit

class Ratings: NSObject {
    
    var zeroStar: Int?
    var oneStar: Int?
    var twoStar: Int?
    var threeStar: Int?
    var fourStar: Int?
    var fiveStar: Int?
    
    override init() {
        
    }
    
    init(zeroStar: Int, oneStar: Int, twoStar: Int, threeStar: Int, fourStar: Int, fiveStar: Int){
        self.zeroStar = zeroStar
        self.oneStar = oneStar
        self.twoStar = twoStar
        self.threeStar = threeStar
        self.fourStar = fourStar
        self.fiveStar = fiveStar
    }
    
}
