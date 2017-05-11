//
//  RecipeReviews.swift
//  student_cookbook
//
//  Created by Jade Redworth on 08/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit

class RecipeReviews: NSObject {
    
    var recipeID: String?
    var recipeReviewID: String?
    var userID: String?
    var review: String?
    var ratingNo: Int?
    
    override init() {
        
    }
    
    init(recipeID: String, recipeReviewID: String, userID: String, review: String, ratingNo: Int){
        self.recipeID = recipeID
        self.recipeReviewID = recipeReviewID
        self.userID = userID
        self.review = review
        self.ratingNo = ratingNo
    }
    
}
