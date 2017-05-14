//
//  EditReviewViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 13/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import Foundation
import FirebaseDatabase

class EditReviewViewController: UIViewController {
    
    var ref: FIRDatabaseReference!

    @IBOutlet weak var labelRating: UILabel!
    @IBOutlet weak var textFieldReview: UITextView!
    
    @IBAction func buttonBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var review = RecipeReviews()
    var recipe = Recipes()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        textFieldReview.text = review.review
        var rating = ""
        rating = rating.getStarRating(rating: "\(review.ratingNo!)")
        labelRating.text = rating
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonSave(_ sender: Any) {
        
        let reviewRef = ref.child("RecipeReviews").child(review.recipeReviewID!)
        reviewRef.updateChildValues(["Review" : textFieldReview.text])
    }
}
