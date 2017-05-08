//
//  RecipeDetailViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 06/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class RecipeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    var userID: String?
    
    // Model
    var recipe: Recipes?
    var imageURL: String?
    var returnValue: Int?
    
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    var userList = [User]()
    var shoppingList = [String]()
    
    var buttonTag: Int = 0
    
    
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
    
    @IBOutlet var starButtons: [UIButton]!
    
    @IBAction func starButtonTapped(_ sender: UIButton) {
        let tag = sender.tag
        
        buttonTag = tag
        
        for button in starButtons {
            if button.tag <= tag {
                button.setImage(UIImage(named: "highlightedStar.png"), for:  UIControlState.normal)
                
                let alert = UIAlertController(title: "Confirm Rating", message: "Would you like to confirm this rating?", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                let yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: setRating)
                
                let no = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil)
                
                alert.addAction(yes)
                alert.addAction(no)
                
                self.present(alert, animated: true, completion: nil)
                
            } else {
                button.setImage(UIImage(named: "emptyStar.png"), for: UIControlState.normal)
                
                let alert = UIAlertController(title: "Confirm Rating", message: "Would you like to confirm this rating?", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                let yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: setRating)
                
                let no = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil)
                
                alert.addAction(yes)
                alert.addAction(no)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBOutlet weak var ingredientsAndStepsTableView: UITableView!
    
    var checked = [Bool]()
    
    // Actions
    @IBAction func buttonCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        userID = (FIRAuth.auth()?.currentUser?.uid)!
        
        fillData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonAddIngredientsToShoppingList(_ sender: Any) {
        let shoppingRef = ref.child("Users").child(userID!).child("ShoppingList")
        
        shoppingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                shoppingRef.setValue(self.shoppingList)
            } else {
                shoppingRef.setValue(self.shoppingList)
            }
        })
        
        let alertController = UIAlertController(title: "Success", message: "Item(s) added to your Shopping List!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func fillData(){
        
        labelRecipeName.text = recipe?.name
        labelServingSize.text = "Serves: \(recipe!.servingSize!)"
        labelPrepTime.text = " \(recipe!.prepTimeHour!) hrs \(recipe!.prepTimeMinute!) mins"
        labelCookTime.text = "\(recipe!.cookTimeHour!) hrs \(recipe!.cookTimeMinute!) mins"
        labelType.text = recipe!.type
        labelCourse.text = (recipe?.course).map { $0.rawValue }
        labelDateAdded.text = "Added: \(recipe!.dateAdded!)"
        labelDifficulty.text = "\(recipe!.difficulty!)"
        
        fillStarRatings()
        
        ingredientsList = recipe!.ingredients
        stepsList = recipe!.steps
        
        imageURL = recipe?.imageURL
        imageViewRecipe.loadImageWithCacheWithUrlString(imageURL!)
        
        fetchUserWhoAddedRecipe(completion: {
            result in
            if result {
                self.labelAddedBy.text = "@: \(self.userList[0].firstName!) \(self.userList[0].lastName!)"
                if let userProfileURL = self.userList[0].profilePicURL {
                    self.imageViewUser.loadImageWithCacheWithUrlString(userProfileURL)
                    self.imageViewUser.makeImageCircle()
                    self.imageViewUser.contentMode = .scaleAspectFill
                }
            }
        })
    }
    
    func fillStarRatings(){
        
        let recipeRating = recipe?.rating
        
        for button in starButtons {
            if button.tag <= recipeRating! {
                button.setImage(UIImage(named: "filledStar.png"), for:  UIControlState.normal)
            }
        }
    }
    
    func fetchUserWhoAddedRecipe(completion: @escaping (Bool) -> ()) {
        userList.fetchUsers(refName: "Users", queryKey: recipe!.addedBy!, queryValue: "" as AnyObject, ref: ref) {
            (result: [User]) in
            if result.isEmpty {
                self.userList = []
            } else {
                self.userList = result
                completion(true)
            }
        }
    }
    
    func setRating(alert: UIAlertAction){
        
        let ratingRef = ref.child("Recipes").child((recipe?.id)!).child("Ratings").child("\(buttonTag)")
        
        ratingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                ratingRef.setValue(1)
            } else {
                var value = snapshot.value as! Int
                value = value + 1
                ratingRef.setValue(value)
            }
            
            let alertController = UIAlertController(title: "Success", message: "Rating: \(self.buttonTag) stars has been saved :)", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    
    
    // MARK: Table View Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnValue: String = ""
        if (section == 0) {
            returnValue = "Ingredients"
        } else if (section == 1){
            returnValue = "Steps"
        }
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        returnValue = 0
        
        if (section == 0) {
            returnValue = ingredientsList.count
        } else if (section == 1) {
            returnValue = stepsList.count
        }
        
        return returnValue!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsAndStepsCell", for: indexPath)
        
        if (indexPath.section == 0) {
            cell.textLabel?.text = ingredientsList[indexPath.row].name
            cell.detailTextLabel?.text = "\(ingredientsList[indexPath.row].quantity!)  \( ingredientsList[indexPath.row].measurement!)"
            
            
        } else if (indexPath.section == 1){
            
            cell.textLabel?.text = (stepsList[indexPath.row].stepNo).map{ String($0)}
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.text = stepsList[indexPath.row].stepDesc
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0){
            if let selectedRow = tableView.cellForRow(at: indexPath) {
                if selectedRow.accessoryType == .none {
                    selectedRow.accessoryType = .checkmark
                    self.shoppingList.append((selectedRow.textLabel?.text)!)
                } else {
                    selectedRow.accessoryType = .none
                    let indexToDelete = self.shoppingList.index(of: (selectedRow.textLabel?.text)!)
                    self.shoppingList.remove(at: indexToDelete!)
                }
            }
        }
    }
}

