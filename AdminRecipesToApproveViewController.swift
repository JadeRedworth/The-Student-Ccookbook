//
//  AdminRecipesToApproveViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 20/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

class AdminRecipesToApproveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    
    // Model
    var recipe: Recipes!
    var imageURL: String?
    var returnValue: Int?
    
    var recipeList = [Recipes]()
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    var userList = [User]()
    
    @IBOutlet weak var ingredientsAndStepsTableView: UITableView!
    
    // Image outlets
    @IBOutlet weak var imageViewRecipe: UIImageView!
    @IBOutlet weak var imageViewUser: UIImageView!
    
    // Label outlets
    @IBOutlet weak var labelRecipeName: UILabel!
    @IBOutlet weak var labelServingSize: UILabel!
    @IBOutlet weak var labelPrepTime: UILabel!
    @IBOutlet weak var labelCookTime: UILabel!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelCourse: UILabel!
    @IBOutlet weak var labelAddedBy: UILabel!
    @IBOutlet weak var labelDateAdded: UILabel!
    @IBOutlet weak var labelDifficulty: UILabel!
    
    @IBOutlet weak var textViewComment: UITextView!
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    var recipeId: String!
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardWhenTappedAround()
        
        ref = FIRDatabase.database().reference()
        uid = FIRAuth.auth()?.currentUser?.uid
        
        if uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        if recipeId.isEmpty{} else {
            getRecipes()
        }
    }
    
    
    func fillData(){
        if self.recipeList.isEmpty { } else {
            self.recipe = self.recipeList[0]
            
            labelRecipeName.text = self.recipe?.name
            labelServingSize.text = "Serves: \(self.recipe!.servingSize!))"
            labelPrepTime.text = " \(String(self.recipe!.prepTimeHour!)) hrs \(self.recipe!.prepTimeMinute!) mins"
            labelCookTime.text = "\(String(self.recipe!.cookTimeHour!)) hrs \(String(self.recipe!.cookTimeMinute!)) mins"
            labelType.text = self.recipe?.type
            labelCourse.text = (self.recipe?.course).map { $0.rawValue }
            labelAddedBy.text = self.recipe!.addedBy
            
            imageURL = self.recipe?.imageURL
            imageViewRecipe.loadImageWithCacheWithUrlString(imageURL!)
        }
    }
    
    func fetchUserWhoAddedRecipe(completion: @escaping (Bool) -> ()) {
        userList.fetchUsers(refName: "Users", queryKey: self.recipe!.addedBy!, queryValue: "" as AnyObject, ref: ref) {
            (result: [User]) in
            if result.isEmpty {
                self.userList = []
            } else {
                self.userList = result
                completion(true)
            }
        }
    }
    
    func getRecipes(){
        recipeList.fetchRecipes(refName: "Recipes", queryKey: "", queryValue: recipeId as AnyObject, recipeToSearch: "", ref: ref) {
            (result: [Recipes]) in
            if result.isEmpty {
                self.recipeList = []
            } else {
                self.recipeList = result
            }
            self.fillData()
        }
    }
    
    func handleLogout() {
        try! FIRAuth.auth()!.signOut()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonApprove(_ sender: Any) {
        updateDatabase(decision: "Approved", resultBool: true)
    }
    
    @IBAction func buttonReject(_ sender: Any) {
        updateDatabase(decision: "Rejected", resultBool: false)
    }
    
    func updateDatabase(decision: String, resultBool: Bool) {
        
        let recipeRef = self.ref.child("Recipes").child((recipe?.id)!).child("Approved")
        recipeRef.setValue(resultBool)
        
        // Add a comment to the recipe, this will be stored in the Firebase Database.
        let commentRef = self.ref.child("AdminRecipeComments").child(recipe.addedBy!).childByAutoId()
        let commentValues = ([
            "RecipeID" : recipeId,
            "RecipeName" : recipe.name!,
            "RecipeImageURL": recipe.imageURL!,
            "Decision" : decision,
            "Date" : "\(Date())",
            "Opened" : false,
            "Comment" : textViewComment.text] as [String : Any])
        commentRef.setValue(commentValues)
        
        // Posts to the Notifcation Center to allow all observers to observe 'getRecipes'
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getRecipes"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "Ingredients"
        } else {
            return "Steps"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0 {
            return self.ingredientsList.count
        } else {
            return self.stepsList.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsAndStepsCell", for: indexPath)
        
        if (indexPath.section == 0) {
            cell.textLabel?.text = ingredientsList[indexPath.row].name
            cell.detailTextLabel?.text = "\(ingredientsList[indexPath.row].quantity!)  \( ingredientsList[indexPath.row].measurement!)"
            
        } else {
            cell.textLabel?.text = (stepsList[indexPath.row].stepNo).map{ String($0)}
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.text = stepsList[indexPath.row].stepDesc
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}


