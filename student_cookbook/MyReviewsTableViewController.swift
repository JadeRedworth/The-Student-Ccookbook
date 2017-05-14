//
//  MyReviewsTableViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 12/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseDatabase

class MyReviewsTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    var reviewListIDs = [String]()
    var reviewList = [RecipeReviews]()
    var recipeList = [Recipes]()
    var recipeID: String!
    
    var userID: String!
    var reviewPressed: Bool = false
    var checkUserReviewRemoval: Bool = false
    var checkedRecipeReviewRemoval: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        userID = (FIRAuth.auth()?.currentUser?.uid)
        
        getReviews()

    }
    
    func getReviews(){
        
        reviewListIDs.removeAll()
        reviewListIDs.fetchUserReviews(refName: "Users", queryKey: userID, ref: ref){
            (result: [String]) in
            if result.isEmpty {
                
            } else {
                self.reviewListIDs = result
                self.reviewList.removeAll()
                for i in 0..<self.reviewListIDs.count {
                    self.reviewList.fetchRecipeReviews(refName: "RecipeReviews", queryKey: "", queryValue: self.reviewListIDs[i], ref: self.ref) {
                        (result: [RecipeReviews]) in
                        if result.isEmpty {
                            print("Result Empty")
                        } else {
                            if self.reviewList.contains(result[0]) {
                                self.reviewList.remove(at: i)
                                self.reviewList.append(result[1])
                                self.tableView.reloadData()
                            } else {
                                self.reviewList += result
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getRecipeDetails(completion: @escaping (Bool) -> ()){
        
        recipeList.fetchRecipes(refName: "Recipes", queryKey: "",queryValue: recipeID as AnyObject, recipeToSearch: "", ref: ref) {
            (result: [Recipes]) in
            if result.isEmpty {
                //self.recipeList = []
            } else {
                if result.count > self.recipeList.count {
                    self.recipeList.removeAll()
                }
                self.recipeList = result
                completion(true)
            }
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewList.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete){
        
                let alert = UIAlertController(title: "❗️", message: "Are you sure you want to delete this review?", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                    
                   self.ref.child("RecipeReviews").child(self.reviewListIDs[indexPath.row]).removeValue(completionBlock: { (error, ref) in
                        if error != nil {
                            self.showAlert(title: "Error", message: "Failed to delete Review")
                            return
                        }
                    })
                    
                    let recipeReviewRef = self.ref.child("Recipes").child(self.recipeList[indexPath.row].id!).child("Reviews")
                    query = recipeReviewRef.queryOrdered(byChild: "RecipeRatingID").queryEqual(toValue: self.reviewListIDs[indexPath.row])
                    query.observe(.value, with: { (snapshot) in
                        let reviewEnumerator = snapshot.children
                        while let reviewItem = reviewEnumerator.nextObject() as? FIRDataSnapshot {
                            let key = reviewItem.key
                            recipeReviewRef.child(key).removeValue()
                            self.checkedRecipeReviewRemoval = true
                            self.go(indexPath: indexPath)
                        }
                    })
                    
                    let userReviewRef = self.ref.child("Users").child(self.reviewList[indexPath.row].userID!).child("Reviews")
                    query = userReviewRef.queryOrdered(byChild: "RecipeReviewID").queryEqual(toValue: self.reviewListIDs[indexPath.row])
                    query.observe(.value, with: { (snapshot) in
                        let userEnumerator = snapshot.children
                        while let userItem = userEnumerator.nextObject() as? FIRDataSnapshot {
                            let key = userItem.key
                            recipeReviewRef.child(key).removeValue()
                            self.checkUserReviewRemoval = true
                            self.go(indexPath: indexPath)
                        }
                    })
                    
                    
                }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func go(indexPath: IndexPath){
        if checkedRecipeReviewRemoval == true && checkUserReviewRemoval == true {
            self.reviewList.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewsCell", for: indexPath) as? UserReviewsTableViewCell
        
        if reviewList.isEmpty {
            
        } else {
            self.recipeID = reviewList[indexPath.row].recipeID
            
           getRecipeDetails(completion: {
                result in
                if result {
                    cell?.labelRecipeName.text = self.recipeList[0].name
                    cell?.photoViewRecipe.loadImageWithCacheWithUrlString(self.recipeList[0].imageURL!)
                    cell?.photoViewRecipe.makeImageCircle()
                    
                }
            })
            
            var starRating: String = ""
            starRating = starRating.getStarRating(rating: "\(self.reviewList[indexPath.row].ratingNo!)")
            cell?.labelStar.text = starRating
            cell?.labelReview.text = self.reviewList[indexPath.row].review
        }
        
        return cell!
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if reviewPressed == true {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reviewPressed = true
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "EditReviewSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        
        if segue.identifier == "EditReviewSegue" {
            let controller = nav.topViewController as! EditReviewViewController
            
            let indexPath = (sender as! NSIndexPath)
            controller.review = reviewList[indexPath.row]
            controller.review.recipeReviewID = reviewListIDs[indexPath.row]
            reviewPressed = false
        }
    }
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
    }
}
