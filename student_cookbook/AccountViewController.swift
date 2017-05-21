//
//  UserAccountViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 04/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//
//
//
// This class is used by 2 View Controllers, therefore, certains checks are needed to determine if the AccountPage 
// is for the Logged in user or for a selected user.
//
//
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
    var loggedInUserList = [User]()
    
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
    
    // View outlets
    @IBOutlet weak var recipeView: UIView!
    @IBOutlet weak var friendsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        loggedInUser = FIRAuth.auth()?.currentUser?.uid
        
        // Check if the user is a guest or authenticated
        if user != nil {
            if user?.userID == loggedInUser {
                fetchUser()
            } else {
                self.friendsList.removeAll()
                loadData()
            }
        } else {
            if loggedInUser == nil {
                perform(#selector(handleLogout), with: nil, afterDelay: 0)
            } else {
                fetchUser()
            }
        }
        
        
        // Add's an Observer to the Notificaition center to observe post from other classes with the relevant name.
        NotificationCenter.default.addObserver(self, selector: #selector(fillData), name: NSNotification.Name(rawValue: "reloadUserData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRecipes), name: NSNotification.Name(rawValue: "reloadRecipes"), object: nil)
    }
    
    func loadData(){
        fillData()
        getRecipe()
        getFriends()
        getReviews()
    }
    
    func fetchUser(){
        
        // Fetch the details for the logged in user.
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

    func handleLogout() {
        try! FIRAuth.auth()!.signOut()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
    
    
    func reloadRecipes() {
        self.getRecipe()
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editAccountDetails(_ sender: Any) {
        if loggedInUser == (FIRAuth.auth()?.currentUser?.uid) {
            performSegue(withIdentifier: "EditAccountDetailsSegue", sender: self)
        }
    }
    
    @IBAction func buttonAddFriend(_ sender: Any) {
        if loggedInUser == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            let userFriendRef = ref.child("UserFriends").child(loggedInUser).childByAutoId()
            userFriendRef.setValue(self.user?.userID)
            self.addFriendButton.setTitle("FOLLOWING", for: .normal)
        }
    }
    
    func fillData(){
        self.userID = self.user?.userID
        self.nameLabel.text = "\(self.user!.firstName!) \(self.user!.lastName!)"
        if let userProfileURL = self.user?.profilePicURL {
            self.imageViewProfilePic.loadImageWithCacheWithUrlString(userProfileURL)
            self.imageViewProfilePic.makeImageCircle()
            self.imageViewProfilePic.contentMode = .scaleAspectFill
        }
        
    }
    
    func getRecipe() {
    
        userRecipeList.fetchRecipes(refName: "Recipes", queryKey: "AddedBy", queryValue: self.userID! as AnyObject, recipeToSearch: "", ref: self.ref) {
            (result: [Recipes]) in
            self.userRecipeList = result
            self.noAddedRecipesLabel.text = "\(self.userRecipeList.count)"
            self.myRecipesCollectionView.reloadData()
        }
        
        userRecipeList.fetchRecipes(refName: "UserRecipes", queryKey: "", queryValue: self.userID! as AnyObject, recipeToSearch: "", ref: self.ref) {
            (result: [Recipes]) in
            self.userRecipeList += result
            self.noAddedRecipesLabel.text = "\(self.userRecipeList.count)"
            self.myRecipesCollectionView.reloadData()
        }
    }
    
    func getFriends(){
        
        let friendIDRef = ref.child("UserFriends").child(userID)
        friendIDRef.observe(.childAdded, with: { (snapshot) in
            self.friendsList.fetchUsers(refName: "Users", queryKey: snapshot.value as! String, queryValue: "" as AnyObject, ref: self.ref) {
                (result: [User]) in
                if result.isEmpty {
                    //self.friendsList = []
                } else {
                    self.friendsList += result
                    self.friendsTableView.reloadData()
                }
            }
        })
        
        if loggedInUser != nil {
            let loggedInFriendRef = ref.child("UserFriends").child(loggedInUser)
            loggedInFriendRef.observe(.childAdded, with: { (snapshot) in
                self.loggedInUserList.fetchUsers(refName: "Users", queryKey: snapshot.value as! String, queryValue: "" as AnyObject, ref: self.ref) {
                    (result: [User]) in
                    if result.isEmpty {
                        print("NoResult")
                    } else {
                        self.loggedInUserList = result
                        if self.loggedInUserList[0].userID == self.user!.userID {
                           // self.addFriendButton.setTitle("FOLLOWING", for: .normal)
                           // self.addFriendButton.isEnabled = false
                        }
                    }
                }
            })
        }
    }
    
    func getReviews(){
        var userIDs: [String] = []
        userIDs.append(userID)
        reviewList.fetchRecipeReviews(refName: "RecipeReviews", queryKey: "UserID", queryValue: userIDs, ref: ref) {
            (result: [RecipeReviews]) in
            if result.isEmpty {
                print("Result Empty")
            } else {
                self.reviewList = result
                self.noRatedRecipesLabel.text = "\(self.reviewList.count)"
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFriend = true
        if loggedInUser != nil {
            if self.friendsList[indexPath.row].userID == loggedInUser {
                performSegue(withIdentifier: "ViewMyAccountDetails", sender: indexPath)
            } else {
                self.user = friendsList[indexPath.row]
                friendsList.removeAll()
                reviewList.removeAll()
                userRecipeList.removeAll()
                loadData()
            }
        } else {
            self.user = friendsList[indexPath.row]
            friendsList.removeAll()
            reviewList.removeAll()
            userRecipeList.removeAll()
            loadData()
        }
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
        } else if identifier == "ViewMyAccountDetails" {
            if loggedInUser != nil {
                if selectedFriend == true {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else if identifier == "EditAccountDetailsSegue" {
            return true
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nav = segue.destination as! UINavigationController
        
        if segue.identifier == "EditAccountDetailsSegue" {
            let controller = nav.topViewController as! EditUserDetailsViewController
            controller.user = self.user
        } else if segue.identifier == "UserRecipeDetails" {
            let controller = nav.topViewController as! RecipeDetailViewController
            let indexPath = (sender as! NSIndexPath)
            let selectedRow = self.userRecipeList[indexPath.row]
            controller.recipeId = selectedRow.id!
            selectedRecipe = false
        } else if segue.identifier == "ViewMyAccountDetails" {
            let controller = nav.topViewController as! AccountViewController
            let indexPath = (sender as! NSIndexPath)
            let selectedRow = self.friendsList[indexPath.row]
            selectedFriend = false
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
