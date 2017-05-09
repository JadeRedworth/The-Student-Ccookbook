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
    
    let cellId = "cellId"
    
    // Model
    var recipe: Recipes?
    var imageURL: String?
    var returnValue: Int?
    
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    var userList = [User]()
    
    var recipeReviewList = [RecipeReviews]()
    var userReviewList = [User]()
    var shoppingList = [String]()
    
    var buttonTag: Int = 0
    var review: String?
    
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
    
    @IBOutlet weak var ingredientsAndStepsTableView: UITableView!
    
    @IBOutlet weak var reviewsTableView: UITableView!
    
    
    //MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        userID = (FIRAuth.auth()?.currentUser?.uid)!
        self.reviewsTableView.register(RecipeDetailsReviewsTableCell.self, forCellReuseIdentifier: cellId)
        
        fillData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Actions
    @IBAction func buttonCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
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
        
        fillStarRatings()
        getReviews()
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

    
    //MARK: Ratings
    
    func fillStarRatings(){
        
        let recipeRating = recipe?.rating
        
        for button in starButtons {
            if button.tag <= recipeRating! {
                button.setImage(UIImage(named: "filledStar.png"), for:  UIControlState.normal)
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
            
            let alert = UIAlertController(title: "Info", message: "Rating :\(self.buttonTag)/5 starts has been successfully Added...Would you like to leave a review?", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let yes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: self.leaveReview)
            
            let no = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil)
            
            alert.addAction(yes)
            alert.addAction(no)
            
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    //MARK: Reviews
    
    func getReviews(){
        
        recipeReviewList.fetchRecipeReviews(refName: "RecipeReviews", queryKey: (recipe?.id)!, ref: ref, completion: {
            (result: [RecipeReviews]) in
            self.recipeReviewList.removeAll()
            self.userReviewList.removeAll()
            self.reviewsTableView.reloadData()
            if result.isEmpty {
            } else {
                self.recipeReviewList = result
                for i in 0..<self.recipeReviewList.count {
                    self.userReviewList.fetchUsers(refName: "Users", queryKey: self.recipeReviewList[i].userID!, queryValue: "" as AnyObject, ref: self.ref) {
                        (result: [User]) in
                        if result.isEmpty {
                            
                        } else {
                            self.userReviewList += result
                            if self.userReviewList.count == self.recipeReviewList.count {
                                self.reviewsTableView.reloadData()
                            }
                        }
                    }
                }
            }
        })
    }
    
    func leaveReview(alert: UIAlertAction){
        
        let alert = UIAlertController(title: "Review", message: "Enter your review..", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Please leave your review!"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.review = textField?.text
            let reviewRef = self.ref.child("RecipeReviews").child((self.recipe?.id)!).child(self.userID!).childByAutoId()
            reviewRef.setValue(["Review": self.review!, "Rating": self.buttonTag])
        }))
        
        self.present(alert, animated:  true, completion: nil)
        
        
    }
    
    
    
    // MARK: Table View Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.ingredientsAndStepsTableView {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnValue: String = ""
        
        if tableView == self.ingredientsAndStepsTableView {
            if (section == 0) {
                returnValue = "Ingredients"
            } else if (section == 1){
                returnValue = "Steps"
            }
        } else if tableView == self.reviewsTableView {
            returnValue = "Reviews"
        }
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        returnValue = 0
        
        if tableView == self.ingredientsAndStepsTableView {
            if (section == 0) {
                returnValue = ingredientsList.count
            } else if (section == 1) {
                returnValue = stepsList.count
            }
        }
        
        if tableView == self.reviewsTableView {
            returnValue = recipeReviewList.count
        }
        
        return returnValue!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.ingredientsAndStepsTableView {
            
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
        
        if tableView == self.reviewsTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RecipeDetailsReviewsTableCell
            
            cell.textLabel?.text = "\(self.userReviewList[indexPath.row].firstName!) \(self.userReviewList[indexPath.row].lastName!)"
            
            var ratingString: String = ""
            let rating: String = "\(recipeReviewList[indexPath.row].ratingNo!)"
            
            switch (rating) {
                
            case "1":
                ratingString = "⭐️"
                break
            case "2":
                ratingString = "⭐️⭐️"
                break
            case "3":
                ratingString = "⭐️⭐️⭐️"
                break
            case "4":
                ratingString = "⭐️⭐️⭐️⭐️"
                break
            case "5":
                ratingString = "⭐️⭐️⭐️⭐️⭐️"
                break
            default:
                break
            }
            
            cell.detailTextLabel?.text = ratingString + " " + self.recipeReviewList[indexPath.row].review!
            
            if let imageURL = self.userReviewList[indexPath.row].profilePicURL {
                cell.userImageView.loadImageWithCacheWithUrlString(imageURL)
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeReviewsCell", for: indexPath)
            cell.textLabel?.text = ""
            return cell
        }
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.reviewsTableView {
            return 100
        } else {
            return 40
        }
    }
}

class RecipeDetailsReviewsTableCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setCircleSize()
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "RecipeReviewsCell")
        
        addSubview(userImageView)
        
        userImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        userImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        userImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

