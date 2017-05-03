//
//  Steps.swift
//  student_cookbook
//
//  Created by Jade Redworth on 04/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit

class Steps: NSObject {
    
    var id: String?
    var stepNo: Int?
    var stepDesc: String?

    override init(){
        
    }
    
    init(id: String, stepNo: Int,stepDesc: String) {
        self.id = id
        self.stepNo = stepNo
        self.stepDesc = stepDesc
    }
}
