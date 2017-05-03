//
//  Ingredients.swift
//  student_cookbook
//
//  Created by Jade Redworth on 04/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit

class Ingredients: NSObject {
    
    var id: String?
    var name: String?
    var quantity: Int?
    var measurement: String?
    
    override init(){
        
    }
    
    init(name: String){
        
    }
    
    init(id: String, name: String, quantity: Int, measurement: String) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.measurement = measurement
    }
}
