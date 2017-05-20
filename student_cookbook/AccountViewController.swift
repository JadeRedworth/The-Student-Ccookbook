//
//  UserAccountViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 04/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AccountViewController: UIViewController, UITabBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    var userID: String!
    var loggedInUser: String!
    var userList = [User]()
    
    var userRecipeList = [Recipes]()
    var friendsList = [User]()
    var reviewList = [RecipeReviews]()
    
    var user: User?
    var selectedRecipe = false
    var selectedFriend = false
    
    var selectedIndexPath: IndexPath?
    
    var searchingUser: Bool = false
    
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    //Label Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var noAddedRecipesLabel: UILabel!
    @IBOutlet weak var noRatedRecipesLabel: UILabel!
    
    @IBOutlet weak var addFriendButton: RoundButton!
    
    @IBOutlet weak var recipesInfoLabel: UILabel!
    
    @IBOutlet weak var myRecipesCollectionView: UICollectionView!
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    // View outlets
    @IBOutlet weak var recipeView: UIView!
    @IBOutlet weak var friendsView: UIView!
    @IBOutlet weak var reviewsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        loggedInUser = (FIRAuth.auth()?.currentUser?.uid)!
        
        if user != nil {
            fillData()
            getRecipe()
            getFriends()
            getReviews()
        } else {
            userList.fetchUsers(refName: "Users", queryKey: loggedInUser, queryValue: "" as AnyObject, ref: ref){
                (result: [User]) in
                if result.isEmpty{
                    print("No user")
                } else {
                    self.user = result[0]
                    self.fillData()
                    self.getRecipe()
                    self.getFriends()
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRecipes), name: NSNotification.Name(rawValue: "reloadRecipes"), object: nil)
    }
    
    func reloadRecipes() {
        self.getRecipe()
    }
    
    @IBAction func segmentControlIndexChanges(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            recipeView.alpha = 1
            friendsView.alpha = 0
            reviewsView.alpha = 0

        case 1:
            recipeView.alpha = 0
            friendsView.alpha = 1
            reviewsView.alpha = 0
        case 2:
            recipeView.alpha = 0
            friendsView.alpha = 0
            reviewsView.alpha = 1
        default:
            break
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editAccountDetails(_ sender: Any) {
        if userID == (FIRAuth.auth()?.currentUser?.uid) {
            performSegue(withIdentifier: "EditAccountDetailsSegue", sender: self)
        }
    }
    
    @IBAction func buttonAddFriend(_ sender: Any) {
        let userFriendRef = ref.child("UserFriends").child(loggedInUser).childByAutoId()
        userFriendRef.setValue(self.user?.userID)
    }
    
    /*func reloadData() {
        fetchUserData()
    }
    
    if self.user == nil {
    userID = (FIRAuth.auth()?.currentUser?.uid)!
    fetchUserData()
    func fetchUserData(){
    userList.fetchUsers(refName: "Users", queryKey: userID, queryValue: "" as AnyObject, ref: ref) {
    (result: [User]) in
    if result.isEmpty {
    self.userList = []
    } else {
    self.userList = result
    self.user = self.userList[0]
    self.fillData()
    }
    }
    }*/
    
    func fillData(){
        self.userID = self.user?.userID
        self.nameLabel.text = "\(self.user!.firstName!) \(self.user!.lastName!)"
        if let userProfileURL = self.user?.profilePicURL {
            self.imageViewProfilePic.loadImageWithCacheWithUrlString(userProfileURL)
            self.imageViewProfilePic.makeImageCircle()
            self.imageViewProfilePic.contentMode = .scaleAspectFill
        }
    
        self.noAddedRecipesLabel.text = "3"
        
        self.noRatedRecipesLabel.text = "2"
        
    }
    
    func getRecipe() {
        userRecipeList.fetchRecipes(refName: "Recipes", queryKey: "AddedBy", queryValue: self.userID! as AnyObject, recipeToSearch: "", ref: self.ref) {
            (result: [Recipes]) in
            self.userRecipeList = result
            self.myRecipesCollectionView.reloadData()
        }
        
        userRecipeList.fetchRecipes(refName: "UserRecipes", queryKey: "", queryValue: self.userID! as AnyObject, recipeToSearch: "", ref: self.ref) {
                (result: [Recipes]) in
            self.userRecipeList += result
            self.myRecipesCollectionView.reloadData()
        }
    }
    
    func getFriends(){
        let friendIDRef = ref.child("UserFriends").child(loggedInUser)
        friendIDRef.observe(.childAdded, with: { (snapshot) in
            self.friendsList.fetchUsers(refName: "Users", queryKey: snapshot.value as! String, queryValue: "" as AnyObject, ref: self.ref) {
                (result: [User]) in
                if result.isEmpty {
                    self.friendsList = []
                    self.friendsTableView.reloadData()
                } else {
                    self.friendsList += result
                    self.friendsTableView.reloadData()
                }
            }
        })
    }
    
    func getReviews(){
        let userIDs: [String] = [""]
        userID.append(userID)
        reviewList.fetchRecipeReviews(refName: "RecipeReviews", queryKey: "UserID", queryValue: userIDs, ref: ref) {
            (result: [RecipeReviews]) in
            if result.isEmpty {
                print("Result Empty")
            } else {
                self.reviewList = result
            }
        }
    }
    
    //MARK: Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.friendsTableView {
            return friendsList.count
        } else {
            return reviewList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.friendsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as? FriendsTableViewCell
            
            if friendsList.isEmpty {
                
            } else {
                
                cell?.labelFriendName.text = "\(self.friendsList[indexPath.row].firstName!) \(self.friendsList[indexPath.row].lastName!)"
                if let profileImageURL = self.friendsList[indexPath.row].profilePicURL {
                    cell?.friendsImageView.loadImageWithCacheWithUrlString(profileImageURL)
                    cell?.friendsImageView.makeImageCircle()
                }
            }
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewsCell", for: indexPath) as? UserReviewsTableViewCell
            
            if reviewList.isEmpty {
                
            } else {
                cell?.labelRecipeName.text = self.reviewList[indexPath.row].recipeID
                var starRating: String = ""
                starRating = starRating.getStarRating(rating: "\(reviewList[indexPath.row].ratingNo!)")
                cell?.labelStar.text = starRating
            }
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFriend = true
        performSegue(withIdentifier: "ViewAccountDetails", sender: indexPath)
    }
    
    //MARK: Collection View Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userRecipeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipesCell", for: indexPath) as! MyCollectionViewCell
        
        cell.recipeImageView.loadImageWithCacheWithUrlString(self.userRecipeList[indexPath.row].imageURL!)
        
        var ratingString: String = ""
        ratingString = ratingString.getStarRating(rating: "\(self.userRecipeList[indexPath.row].averageRating!)")
        
        cell.labelRecipeName.numberOfLines = 0
        cell.labelRecipeName.text = "\(self.userRecipeList[indexPath.row].name!) \n \(ratingString)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selectedRecipe = true
        self.performSegue(withIdentifier: "UserRecipeDetails", sender: indexPath)
    }
    
    //MARK: Segue
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "UserRecipeDetails" {
            if selectedRecipe == true {
                return true
            } else {
                return false
            }
        } else {
            if selectedFriend == true {
                return true
            } else {
                return false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nav = segue.destination as! UINavigationController
        
        if segue.identifier == "EditAccountDetailsSegue" {
            let controller = nav.topViewController as! EditUserDetailsViewController
            controller.user = self.user
        } else if segue.identifier == "UserRecipeDetails" {
            let indexPath = (sender as! NSIndexPath)
            let controller = nav.topViewController as! RecipeDetailViewController
            let selectedRow = userRecipeList[indexPath.row]
            controller.recipeId = selectedRow.id!
            selectedRecipe = false
        } else if segue.identifier == "ViewAccountDetails" {
            let indexPath = (sender as! NSIndexPath)
            let controller = nav.topViewController as! AccountViewController
            let selectedRow = friendsList[indexPath.row]
            controller.user = selectedRow
        }
    }
}

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var labelRecipeName: UILabel!
}

class FriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendsImageView: UIImageView!
    @IBOutlet weak var labelFriendName: UILabel!
}
