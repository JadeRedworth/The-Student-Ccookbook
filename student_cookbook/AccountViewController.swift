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

class AccountViewController: UIViewController, UITabBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    var userID: String!
    var userList = [User]()
    var userRecipeList = [Recipes]()
    var user: User?
    var selectedRecipe = false
    
    var selectedIndexPath: IndexPath?
    
    var searchingUser: Bool = false
    
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    //Label Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var noAddedRecipesLabel: UILabel!
    @IBOutlet weak var noRatedRecipesLabel: UILabel!
    @IBOutlet weak var noCookedRecipesLabel: UILabel!
   
    @IBOutlet weak var editButton: RoundButton!
    @IBOutlet weak var addFriendButton: RoundButton!
    
    @IBOutlet weak var recipesInfoLabel: UILabel!
    
    @IBOutlet weak var myRecipesCollectionView: UICollectionView!
    
   // @IBOutlet weak var userInfoTableView: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        if self.user == nil {
            userID = (FIRAuth.auth()?.currentUser?.uid)!
            fetchUserData()
            editButton.isHidden = false
            addFriendButton.isHidden = true
        } else {
            fillData()
            editButton.isHidden = true
            addFriendButton.isHidden = false
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
    }
    
    @IBAction func editAccountDetails(_ sender: Any) {
        if userID == (FIRAuth.auth()?.currentUser?.uid) {
            performSegue(withIdentifier: "EditAccountDetailsSegue", sender: self)
        }
    }
    
    func reloadData() {
        fetchUserData()
    }
    
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
    }
    
    func fillData(){
        self.userID = self.user?.userID
        self.nameLabel.text = "\(self.user!.firstName!) \(self.user!.lastName!)"
        self.ageLabel.text = "\(self.user!.age!) y/o"
        self.genderLabel.text = self.user?.gender
        if let userProfileURL = self.user?.profilePicURL {
            self.imageViewProfilePic.loadImageWithCacheWithUrlString(userProfileURL)
            self.imageViewProfilePic.makeImageCircle()
            self.imageViewProfilePic.contentMode = .scaleAspectFill
        }
        
        userRecipeList.fetchRecipes(refName: "Recipes", queryKey: "AddedBy", queryValue: self.userID! as AnyObject, ref: self.ref) {
            (result: [Recipes]) in
            print(result)
            self.userRecipeList = result
            self.myRecipesCollectionView.reloadData()
            
            if self.userRecipeList.count > 0 {
                self.myRecipesCollectionView.isHidden = false
                self.recipesInfoLabel.isHidden = true
            } else {
                self.myRecipesCollectionView.isHidden = true
                self.recipesInfoLabel.isHidden = false
            }

        }
    }
    //MARK: Collection View Methods
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userRecipeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipesCell", for: indexPath) as! MyCollectionViewCell
        
        cell.recipeImageView.loadImageWithCacheWithUrlString(self.userRecipeList[indexPath.row].imageURL!)
        cell.recipeName.text = self.userRecipeList[indexPath.row].name
        
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
            return true
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
            controller.recipe = selectedRow
            selectedRecipe = false
        }
    }
}

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
}
