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
    var recipeList = [Recipes]()
    
    var recipeReviewList = [RecipeReviews]()
    var recipeReviewIDs = [String]()
    var userReviewList = [User]()
    var shoppingList = [String]()
    
    var buttonTag: Int = 0
    var review: String?
    var recipeRating:Int = 0
    var recipeId: String = ""
    
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
    @IBOutlet weak var labelAverageRating: UILabel!
    @IBOutlet weak var labelNoOfReviews: UILabel!
    
    @IBOutlet var starButtons: [UIButton]!
    
    @IBOutlet weak var ingredientsAndStepsTableView: UITableView!
    
    @IBOutlet weak var reviewsTableView: UITableView!
    
    @IBOutlet weak var buttonEdit: UIBarButtonItem!
    
    @IBAction func buttonEdit(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "EditRecipeSegue", sender: nil)
        
    }
    
    //MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        userID = (FIRAuth.auth()?.currentUser?.uid)!
    
        self.reviewsTableView.register(RecipeDetailsReviewsTableCell.self, forCellReuseIdentifier: cellId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        
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
    
    func reloadData(){
        fillData()
    }
    
    func fillData(){
        
        recipeList.fetchRecipes(refName: "Recipes", queryKey: "",queryValue: recipeId as AnyObject, recipeToSearch: "", ref: ref) {
            (result: [Recipes]) in
            if result.isEmpty {
                self.recipeList = []
            } else {
                self.recipeList = result
                self.recipe = self.recipeList[0]
                if self.recipe?.addedBy == self.userID {
                    self.buttonEdit.isEnabled = true
                    self.buttonEdit.tintColor = .white
                } else {
                    self.buttonEdit.isEnabled = false
                    self.buttonEdit.tintColor = .clear
                }
                self.labelRecipeName.text = self.recipe?.name
                self.labelServingSize.text = "Serves: \(self.recipe!.servingSize!)"
                self.labelPrepTime.text = " \(self.recipe!.prepTimeHour!) hrs \(self.recipe!.prepTimeMinute!) mins"
                self.labelCookTime.text = "\(self.recipe!.cookTimeHour!) hrs \(self.recipe!.cookTimeMinute!) mins"
                self.labelType.text = self.recipe!.type
                self.labelCourse.text = (self.recipe?.course).map { $0.rawValue }
                self.labelDateAdded.text = "Added: \(self.recipe!.dateAdded!)"
                self.labelDifficulty.text = "\(self.recipe!.difficulty!)"
                self.recipeRating = self.recipe!.averageRating!
                self.ingredientsList = self.recipe!.ingredients
                self.stepsList = self.recipe!.steps
                
                self.ingredientsAndStepsTableView.reloadData()
                
                self.imageURL = self.recipe?.imageURL
                self.imageViewRecipe.loadImageWithCacheWithUrlString(self.imageURL!)
                
                self.fetchUserWhoAddedRecipe(completion: {
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
                
                self.fillStarRatings()
                self.getReviews()
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
    
    
    //MARK: Ratings
    
    func fillStarRatings(){
        
        for button in starButtons {
            if button.tag <= recipeRating {
                button.setImage(UIImage(named: "filledStar.png"), for:  UIControlState.normal)
            }
        }
        
        var ratingString: String = ""
        ratingString = ratingString.getStarRating(rating: "\(recipeRating)")
        labelAverageRating.text = ratingString
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
        
        recipeReviewIDs.fetchRecipeReviews(refName: "Recipes", queryKey: (recipe?.id)!, ref: ref) {
            (result: [String]) in
            if result.isEmpty {
               
            } else {
                self.recipeReviewIDs = result
                for i in 0..<self.recipeReviewIDs.count {
                    self.recipeReviewList.fetchRecipeReviews(refName: "RecipeReviews", queryKey: "", queryValue: self.recipeReviewIDs[i], ref: self.ref, completion: {
                        (result: [RecipeReviews]) in
                        self.recipeReviewList.removeAll()
                        self.userReviewList.removeAll()
                        self.reviewsTableView.reloadData()
                        if result.isEmpty {
                            self.labelNoOfReviews.text = "0 reviews"
                        } else {
                            self.recipeReviewList = result
                            self.labelNoOfReviews.text = "\(self.recipeReviewList.count) reviews"
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
            }
        }
    }
    
    func leaveReview(alert: UIAlertAction){
        
        let alert = UIAlertController(title: "Review", message: "Enter your review..", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Please leave your review!"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.review = textField?.text
            let reviewRef = self.ref.child("RecipeReviews").childByAutoId()
            reviewRef.setValue(["RecipeID": self.recipe?.id! as Any, "UserID": self.userID!, "Review": self.review!, "Rating": self.buttonTag])
            let userRef = self.ref.child("Users").child(self.userID!).child("Reviews").childByAutoId()
            userRef.setValue(["RecipeReviewID": reviewRef.key])
            let recipeRef = self.ref.child("Recipes").child((self.recipe?.id!)!).child("Reviews").childByAutoId()
            recipeRef.setValue(["RecipeRatingID": reviewRef.key])
        }))
        
        self.present(alert, animated:  true, completion: nil)
        fillData()
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeReviewsCell", for: indexPath) as! RecipeDetailsReviewsTableCell
            
            
            let rating: String = "\(recipeReviewList[indexPath.row].ratingNo!)"
            var ratingString: String = ""
            ratingString = ratingString.getStarRating(rating: rating)
            
            cell.labelUserName?.text = "\(self.userReviewList[indexPath.row].firstName!) \(self.userReviewList[indexPath.row].lastName!)"
            cell.labelReviewStars.text = ratingString
            cell.labelReview.text = self.recipeReviewList[indexPath.row].review
            
            if let imageURL = self.userReviewList[indexPath.row].profilePicURL {
                cell.userReviewImageView.loadImageWithCacheWithUrlString(imageURL)
                cell.userReviewImageView.makeImageCircle()
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeReviewsCell", for: indexPath) as! RecipeDetailsReviewsTableCell
            cell.labelUserName.text = ""
            cell.labelReview.text = ""
            cell.labelReviewStars.text = ""
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        
        if segue.identifier == "EditRecipeSegue" {
            let controller = nav.topViewController as! AddRecipeViewController
            controller.recipe = recipe!
            controller.editCheck = true
        }
    }
}

class RecipeDetailsReviewsTableCell: UITableViewCell {
    
    @IBOutlet weak var userReviewImageView: UIImageView!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelReviewStars: UILabel!
    @IBOutlet weak var labelReview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
