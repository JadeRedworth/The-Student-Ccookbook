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
    
    var searchingUser: Bool = false
    
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    //Label Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var noAddedRecipesLabel: UILabel!
    @IBOutlet weak var noRatedRecipesLabel: UILabel!
    @IBOutlet weak var noCookedRecipesLabel: UILabel!
    
    @IBOutlet weak var myRecipesCollectionView: UICollectionView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        if searchingUser == false {
            userID = (FIRAuth.auth()?.currentUser?.uid)!
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        fetchUserData()
        
        
        userRecipeList.fetchRecipes(refName: "Recipes", queryKey: "AddedBy", queryValue: self.userID! as AnyObject, ref: ref) {
            (result: [Recipes]) in
            print(result)
            self.userRecipeList = result
            self.myRecipesCollectionView.reloadData()
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
                self.nameLabel.text = "\(self.user!.firstName!) \(self.user!.lastName!)"
                self.emailLabel.text = self.user!.email!
                self.ageLabel.text = "\(self.user!.age!) years"
                self.genderLabel.text = self.user?.gender
                self.locationLabel.text = self.user?.location
                if let userProfileURL = self.user?.profilePicURL {
                    self.imageViewProfilePic.loadImageWithCacheWithUrlString(userProfileURL)
                    self.imageViewProfilePic.makeImageCircle()
                    self.imageViewProfilePic.contentMode = .scaleAspectFill
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "ShowRecipeDetails", sender: indexPath.row)
          
    }
    
    //MARK: Collection View Methods
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userRecipeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyRecipesCell", for: indexPath) as! MyCollectionViewCell
        
        cell.recipeImageView.loadImageWithCacheWithUrlString(self.userRecipeList[indexPath.row].imageURL!)
        cell.recipeName.text = self.userRecipeList[indexPath.row].name
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        
        if segue.identifier == "EditAccountDetailsSegue" {
            let controller = nav.topViewController as! EditUserDetailsViewController
                controller.user = self.user
        } else if segue.identifier == "ShowRecipeDetails" {
            
            let controller = nav.topViewController as! RecipeDetailViewController
            let indexPath = (sender as! NSIndexPath)
            let selectedRow = userRecipeList[indexPath.row]
            controller.recipe = selectedRow
        }
    }
    
}

class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeName: UILabel!
    
}
