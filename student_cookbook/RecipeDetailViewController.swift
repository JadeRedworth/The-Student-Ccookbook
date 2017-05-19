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

class RecipeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
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
    
    var isFavourite: Bool = false
    var lastSelectedIndexPath: IndexPath!
    
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
    
    @IBOutlet weak var buttonAddFavourite: UIButton!
    
    @IBOutlet var starButtons: [UIButton]!
    @IBOutlet weak var textViewReview: UITextView!
    @IBOutlet weak var buttonAddReview: UIButton!
    
    @IBOutlet weak var ingredientsAndStepsTableView: UITableView!
    
    @IBOutlet weak var reviewsTableView: UITableView!
    
    @IBOutlet weak var buttonEdit: UIBarButtonItem!
    
    @IBAction func buttonEdit(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "EditRecipeSegue", sender: nil)
    }
    
    @IBAction func buttonAddFavourite(_ sender: UIButton){
        if isFavourite == true {
            self.showAlert(title: "Error", message: "This recipe has already been added to your Favourites.")
        } else {
            let favValue = ["RecipeID": self.recipe?.id]
            ref.child("Users").child(self.userID!).child("Favourites").childByAutoId().setValue(favValue)
            self.showAlert(title: "Success", message: "Recipe has been added to Favourites.")
            self.buttonAddFavourite.setImage(UIImage(named: "filledHeart.png"), for:  UIControlState.normal)
        }
    }
    
    //MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        userID = (FIRAuth.auth()?.currentUser?.uid)!
        
        self.ingredientsAndStepsTableView.estimatedRowHeight = 70.0
        self.ingredientsAndStepsTableView.rowHeight = UITableViewAutomaticDimension
        
        self.reviewsTableView.estimatedRowHeight = 85
        self.reviewsTableView.rowHeight = UITableViewAutomaticDimension
        
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
            } else {
                button.setImage(UIImage(named: "emptyStar.png"), for: UIControlState.normal)
            }
        }
    }
    
    @IBAction func buttonAddReview(_ sender: Any) {
        
        if textViewReview.text.isEmpty {
            buttonAddReview.titleLabel?.text = "Save Rating"
            setRating()
        } else {
            buttonAddReview.titleLabel?.text = "Add Review"
            setRating()
            leaveReview()
        }
        textViewReview.text = ""
        self.fillStarRatings()
        self.getReviews()
    }
    
    @IBAction func buttonAddIngredientsToShoppingList(_ sender: Any) {
        let shoppingRef = ref.child("Users").child(userID!).child("ShoppingList")
        
        shoppingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                shoppingRef.setValue(self.shoppingList)
            } else {
                let shoppingEnumerator = snapshot.children
                while let shoppingItem = shoppingEnumerator.nextObject() as? FIRDataSnapshot {
                    if self.shoppingList.contains(shoppingItem.value as! String){
                        let alertController = UIAlertController(title: "Error", message: "\(shoppingItem.value!) is already in your shopping list!", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.shoppingList.append(shoppingItem.value as! String)
                    }
                }
                shoppingRef.setValue(self.shoppingList)
                let alertController = UIAlertController(title: "Success", message: "Item(s) added to your Shopping List!", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        })
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
                
                let userRef = self.ref.child("Users").child(self.userID!).child("Favourites")
                query = userRef.queryOrdered(byChild: "RecipeID").queryEqual(toValue: self.recipe?.id)
                query.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        self.isFavourite = true
                        self.buttonAddFavourite.setImage(UIImage(named: "filledHeart.png"), for:  UIControlState.normal)
                    }
                })
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
            button.setImage(UIImage(named: "emptyStar.png"), for: UIControlState.normal)
        }
        
        for button in starButtons {
            if button.tag <= recipeRating {
                button.setImage(UIImage(named: "filledStar.png"), for:  UIControlState.normal)
            }
        }
        
        var ratingString: String = ""
        ratingString = ratingString.getStarRating(rating: "\(recipeRating)")
        labelAverageRating.text = ratingString
    }
    
    func setRating(){
        
        let ratingRef = ref.child("Recipes").child((recipe?.id)!).child("Ratings").child("\(buttonTag)")
        
        ratingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                ratingRef.setValue(1)
            } else {
                var value = snapshot.value as! Int
                value = value + 1
                ratingRef.setValue(value)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadRecipes"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        })
    }
    
    //MARK: Reviews
    
    func getReviews(){
        
        recipeReviewIDs.fetchRecipeReviews(refName: "Recipes", queryKey: (recipe?.id)!, ref: ref) {
            (result: [String]) in
            if result.isEmpty {
                self.labelNoOfReviews.text = "0 reviews"
            } else {
                self.recipeReviewIDs = result
                self.recipeReviewList.fetchRecipeReviews(refName: "RecipeReviews", queryKey: "", queryValue: self.recipeReviewIDs, ref: self.ref, completion: {
                    (result: [RecipeReviews]) in
                    self.recipeReviewList.removeAll()
                    if result.isEmpty {
                        
                    } else {
                        self.recipeReviewList = result
                        self.labelNoOfReviews.text = "\(self.recipeReviewList.count) reviews"
                        self.reviewsTableView.reloadData()
                    }
                })
            }
        }
    }
    
    func leaveReview(){
        
        self.review = textViewReview.text
        
        let reviewRef = self.ref.child("RecipeReviews").childByAutoId()
        reviewRef.setValue(["RecipeID": self.recipe?.id! as Any, "UserID": self.userID!, "Review": self.review!, "Rating": self.buttonTag])
        let userRef = self.ref.child("Users").child(self.userID!).child("Reviews").childByAutoId()
        userRef.setValue(["RecipeReviewID": reviewRef.key])
        let recipeRef = self.ref.child("Recipes").child((self.recipe?.id!)!).child("Reviews").childByAutoId()
        recipeRef.setValue(["RecipeRatingID": reviewRef.key])
        
        
        //self.present(alert, animated:  true, completion: nil)
        
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsAndStepsCell", for: indexPath) as! IngredientsAndStepsTableViewCell
            
            if (indexPath.section == 0) {
                cell.labelDetail?.text = ingredientsList[indexPath.row].name
                cell.labelTitle?.text = "\(ingredientsList[indexPath.row].quantity!)  \( ingredientsList[indexPath.row].measurement!)"
                
            } else if (indexPath.section == 1){
                
                cell.labelTitle?.text = (stepsList[indexPath.row].stepNo).map{ String($0)}
                cell.labelDetail?.text = stepsList[indexPath.row].stepDesc
            }
            
            cell.labelDetail?.preferredMaxLayoutWidth = tableView.bounds.width
            
            return cell
        }
        
        if tableView == self.reviewsTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeReviewsCell", for: indexPath) as! RecipeDetailsReviewsTableCell
            
            
            let rating: String = "\(recipeReviewList[indexPath.row].ratingNo!)"
            var ratingString: String = ""
            ratingString = ratingString.getStarRating(rating: rating)
            
            self.userReviewList.fetchUsers(refName: "Users", queryKey: self.recipeReviewList[indexPath.row].userID!, queryValue: "" as AnyObject, ref: self.ref) {
                (result: [User]) in
                cell.labelUserName?.text = "\(result[0].firstName!) \(result[0].lastName!)"
                if let imageURL = result[0].profilePicURL {
                    cell.userReviewImageView.loadImageWithCacheWithUrlString(imageURL)
                    cell.userReviewImageView.makeImageCircle()
                }
            }
            
            cell.labelReviewStars.text = ratingString
            cell.labelReview.text = self.recipeReviewList[indexPath.row].review
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeReviewsCell", for: indexPath) as! RecipeDetailsReviewsTableCell
            cell.labelUserName.text = ""
            cell.labelReview.text = ""
            cell.labelReviewStars.text = ""
            return cell
        }
    }
    
    func calculateHeightForConfiguredSizingCell(sizingCell: UITableViewCell) -> CGFloat {
        sizingCell.layoutIfNeeded()
        let size = sizingCell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return size.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.reviewsTableView {
            return UITableViewAutomaticDimension
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
     var returnValue: Int = 0
        if tableView == self.ingredientsAndStepsTableView {
            if indexPath.section == 0 {
                returnValue = UITableViewCellEditingStyle(rawValue: 3)!.rawValue
            }
        }
        return UITableViewCellEditingStyle(rawValue: returnValue)!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var returnValue: Bool = false
        if tableView == self.ingredientsAndStepsTableView {
            if indexPath.section == 0 {
                returnValue = true
            }
        }
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.ingredientsAndStepsTableView {
            if (indexPath.section == 0){
                if let selectedRow = tableView.cellForRow(at: indexPath) as? IngredientsAndStepsTableViewCell {
                    if selectedRow.accessoryType == .none {
                        selectedRow.accessoryType = .checkmark
                        self.shoppingList.append((selectedRow.labelDetail?.text)!)
                    } else {
                        selectedRow.accessoryType = .none
                        let indexToDelete = self.shoppingList.index(of: (selectedRow.labelDetail?.text)!)
                        self.shoppingList.remove(at: indexToDelete!)
                    }
                }
            }
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
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
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
    }
    
}

class IngredientsAndStepsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetail: UILabel!
}
