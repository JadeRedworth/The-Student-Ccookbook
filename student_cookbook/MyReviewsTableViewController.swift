//
//  MyReviewsTableViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 12/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MyReviewsTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    var reviewListIDs = [String]()
    var reviewList = [RecipeReviews]()
    
    var userID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        userID = (FIRAuth.auth()?.currentUser?.uid)
        
        getReviews()
        self.tableView.reloadData()

    }
    
    func getReviews(){
        
        reviewListIDs.fetchUserReviews(refName: "Users", queryKey: userID, ref: ref){
            (result: [String]) in
            if result.isEmpty {
                
            } else {
                self.reviewListIDs = result
                for i in 0..<self.reviewListIDs.count {
                    self.reviewList.fetchRecipeReviews(refName: "RecipeReviews", queryKey: "", queryValue: self.reviewListIDs[i], ref: self.ref) {
                        (result: [RecipeReviews]) in
                        if result.isEmpty {
                            print("Result Empty")
                        } else {
                            self.reviewList = result
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reviewList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewsCell", for: indexPath) as? UserReviewsTableViewCell
        
        if reviewList.isEmpty {
            
        } else {
            cell?.labelRecipeName.text = self.reviewList[indexPath.row].recipeID
            var starRating: String = ""
            starRating = starRating.getStarRating(rating: "\(reviewList[indexPath.row].ratingNo!)")
            cell?.labelStar.text = starRating
            cell?.labelReview.text = self.reviewList[indexPath.row].review
        }
        
        return cell!
    }
}

