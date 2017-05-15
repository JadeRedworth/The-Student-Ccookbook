//
//  AddRecipeViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 05/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AddRecipeViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate,  UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var segmentConrtolViews: UISegmentedControl!
    
    // Views
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var ingredientsView: UIView!
    @IBOutlet weak var stepsView: UIView!
    
    // Info
    @IBOutlet weak var textFieldRecipeName: UITextField!
    @IBOutlet weak var textFieldServingSize: UITextField!
    @IBOutlet weak var textFieldDifficulty: UITextField!
    @IBOutlet weak var textFieldPrepHour: UITextField!
    @IBOutlet weak var textFieldPrepMin: UITextField!
    @IBOutlet weak var textFieldCookHour: UITextField!
    @IBOutlet weak var textFieldCookMin: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var switchPubPriv: UISwitch!
    @IBOutlet weak var textFieldCourse: UITextField!
    @IBOutlet weak var textFieldType: UITextField!
    
    // Ingredients
    @IBOutlet weak var textFieldIngredientName: UITextField!
    @IBOutlet weak var textFieldIngredientsQuantity: UITextField!
    @IBOutlet weak var textFieldMeasurement: UITextField!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var buttonAddIngredients: UIButton!
    
    // Steps
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var buttonAddSteps: UIButton!
    @IBOutlet weak var textViewSteps: UITextView!
    
    // Ipad outlets
    @IBOutlet weak var IngredientsAndStepsTableView: UITableView!
    
    
    // Variables
    // Recipes
    var recipe = Recipes()
    var recipeID: String!
    
    // Ingredients
    var ingredientsID: String!
    var ingredientsList = [Ingredients]()
    
    // Steps
    var stepsID: String!
    var stepsList =  [Steps]()
    
    var refHandle: UInt!
    var ref, recipeRef, ingredientsRef, stepsRef, ratingRef, reviewRef: FIRDatabaseReference!
    
    var returnValue: Int!
    var recipeDocument: String = ""
    var count: Int = 0
    
    var ingredientToEdit: Int!
    var stepToEdit: Int!
    
    // current user ID
    var userID: String!
    
    var adminStatus: Bool! = false
    var publicStatus: Bool! = false
    var cookHour: Bool! = false
    var cookMin: Bool! = false
    var prepHour: Bool! = false
    var prepMin: Bool! = false
    var editCheck: Bool! = false
    var editIngredients: Bool! = false
    var editSteps: Bool! = false
    var recipeUpdated: Bool! = false
    
    // Picker Lists
    var courses = ["Breakfast","Lunch","Dinner", "Dessert"]
    var types = ["Quick", "Healthy", "Easy", "On a Budget", "Treat your self"]
    var measurements = ["Cup", "Grams", "ml", "Oz", "Tbsp", "tsp"]
    var difficulty = ["1", "2", "3", "4", "5"]
    var timeHours: [String] = []
    var timeMins: [String] = []
    
    var pickerView = UIPickerView()
    var datasource = [String]()
    
    var currentStoryboard: UIStoryboard!
    var currentStoryboardName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardWhenTappedAround()
        self.dismissKeyboard()
        
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        ref = FIRDatabase.database().reference()
        self.userID = FIRAuth.auth()?.currentUser?.uid
        currentStoryboard = self.storyboard
        self.currentStoryboardName = currentStoryboard.value(forKey: "name") as! String
        
        checkIfUserIsLoggedIn()
        checkIfUserIsAdmin()
        setUpViews()
        
        buttonAddSteps.layer.cornerRadius = 5
        buttonAddIngredients.layer.cornerRadius = 5
        
        self.timeHours = [Int] (0...23).map{ String($0)}
        self.timeMins = [Int] (0...59).map{ String($0)}
        
        pickerView.delegate = self
        
        setUpPickerViews()
        
        setUpToolBar()
        
        if currentStoryboardName == "Main" {
            self.stepsTableView.estimatedRowHeight = 44.0
            self.stepsTableView.rowHeight = UITableViewAutomaticDimension
        }
        
        publicStatus = false
        
        if editCheck == true {
            fillRecipeInformation()
        }
    }
    
    func setUpViews() {
        
        if currentStoryboardName == "Main" {
            infoView.alpha = 1
            ingredientsView.alpha = 0
            stepsView.alpha = 0
        }
    }
    
    func setUpPickerViews(){
        
        textFieldMeasurement.inputView = pickerView
        textFieldType.inputView = pickerView
        textFieldCourse.inputView = pickerView
        textFieldDifficulty.inputView = pickerView
        textFieldCookHour.inputView = pickerView
        textFieldCookMin.inputView = pickerView
        textFieldPrepHour.inputView = pickerView
        textFieldPrepMin.inputView = pickerView
        
        textFieldMeasurement.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        textFieldCourse.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        textFieldType.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        textFieldDifficulty.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        textFieldCookHour.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        textFieldCookMin.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        textFieldPrepHour.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        textFieldPrepMin.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
    }
    
    func fillRecipeInformation() {
        recipeID = recipe.id
        let imageURL = recipe.imageURL
        photoImageView.loadImageWithCacheWithUrlString(imageURL!)
        textFieldRecipeName.text = recipe.name
        textFieldServingSize.text = "\(recipe.servingSize!)"
        textFieldCourse.text = recipe.course?.rawValue
        textFieldType.text = recipe.type
        textFieldDifficulty.text = "\(recipe.difficulty!)"
        textFieldCookHour.text = "\(recipe.cookTimeHour!)"
        textFieldCookMin.text = "\(recipe.cookTimeMinute!)"
        textFieldPrepHour.text = "\(recipe.prepTimeHour!)"
        textFieldPrepMin.text = "\(recipe.prepTimeMinute!)"
        ingredientsList = recipe.ingredients
        stepsList = recipe.steps
    }
    
    
    // MARK: Handle User Login
    
    // Check if users is logged in
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    // log out user if they are not logged in
    func handleLogout() {
        try! FIRAuth.auth()!.signOut()
        
        if currentStoryboardName == "Main" {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            present(vc!, animated: true, completion: nil)
        } else {
            let vc = UIStoryboard(name: "Ipad", bundle: nil).instantiateInitialViewController()
            present(vc!, animated: true, completion: nil)
        }
    }
    
    // Check if user is an admin
    func checkIfUserIsAdmin(){
        let userRef = ref.child("Users").child(self.userID)
        userRef.observe(.value, with: { (snapshot) in
            
            print(snapshot)
            if let userDict = snapshot.value as? [String: AnyObject] {
                self.adminStatus = userDict["Admin"] as! Bool!
            }
        })
    }
    
    // MARK: Actions
    
    @IBAction func segmentControlViewsIpad(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            ingredientsView.alpha = 1
            stepsView.alpha = 0
        case 1:
            ingredientsView.alpha = 0
            stepsView.alpha = 1
        default:
            break;
        }
        
    }
    
    @IBAction func segmentControlViews(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            infoView.alpha = 1
            ingredientsView.alpha = 0
            stepsView.alpha = 0
        case 1:
            infoView.alpha = 0
            ingredientsView.alpha = 1
            stepsView.alpha = 0
        case 2:
            infoView.alpha = 0
            ingredientsView.alpha = 0
            stepsView.alpha = 1
        default:
            break;
        }
    }
    
    // Siwtch
    @IBAction func switchPubPriv(_ sender: Any) {
        if switchPubPriv.isOn {
            publicStatus = true
        } else {
            publicStatus = false
        }
    }
    
    // Button cancel
    @IBAction func buttonCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonAddIngredients(_ sender: UIButton) {
        
        let ingredients = Ingredients()
        if textFieldIngredientName.text != "" && textFieldIngredientsQuantity.text != nil && textFieldMeasurement.text != "" {
            
            ingredients.name = textFieldIngredientName.text!
            ingredients.quantity = Int(textFieldIngredientsQuantity.text!)
            ingredients.measurement = textFieldMeasurement.text!
            
            
            if editIngredients == true {
                ingredientsList[ingredientToEdit].name = ingredients.name
                ingredientsList[ingredientToEdit].quantity = ingredients.quantity
                ingredientsList[ingredientToEdit].measurement = ingredients.measurement
                editIngredients = false
                
            } else {
                ingredientsList.append(ingredients)
            }
            
            if currentStoryboardName == "Main" {
                ingredientsTableView.reloadData()
            } else {
                IngredientsAndStepsTableView.reloadData()
            }
            
            textFieldIngredientName.text = ""
            textFieldIngredientsQuantity.text = ""
            textFieldMeasurement.text = ""
            self.buttonAddIngredients.setTitle("Add Ingredient", for: .normal)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please make sure all fields have input!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonAddSteps(_ sender: UIButton) {
        
        let steps = Steps()
        
        if textViewSteps.text != "" {
            
            if editSteps == true {
                stepsList[stepToEdit].stepDesc = steps.stepDesc
                steps.stepNo = stepsList[stepToEdit].stepNo
            } else {
                steps.stepDesc = textViewSteps.text
                steps.stepNo = stepsList.count + 1
                stepsList.append(steps)
            }
            
            if currentStoryboardName == "Main" {
                stepsTableView.reloadData()
            
            } else {
                IngredientsAndStepsTableView.reloadData()
            }
            
            textViewSteps.text = ""
            self.buttonAddSteps.setTitle("Add Step", for: .normal)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please enter a step!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // Button to add recipe
    @IBAction func buttonSaveRecipe(_ sender: Any) {
        
        getRecipeDataToAdd(completion: {
            result in
            if result {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func checkInfo() -> Bool {
        var result: Bool = false
        if !ingredientsList.isEmpty {
            if !stepsList.isEmpty {
                let textFieldStatus = checkTextFields()
                if textFieldStatus == false {
                    result = true
                } else {
                    showAlert(title: "Error", message: "Please make sure all recipe information is complete!")
                }
            } else {
                showAlert(title: "Error", message: "Please Add Steps!")
            }
        } else {
            showAlert(title: "Error", message: "Please Add Ingredients")
        }
        return result
    }
    
    func getRecipeDataToAdd(completion: @escaping (Bool) -> ()) {
        
        if checkInfo() == true {
            var photoImageURL: String = ""
            photoImageURL.storeImage(image: photoImageView.image) {
                (result: String) in
                if !result.isEmpty {
                    photoImageURL = result
                    
                    if self.currentStoryboardName == "Ipad" {
                        self.adminStatus = true
                    } else {
                        self.adminStatus = false
                    }
                    
                    let recipeValues = [
                        "Name": self.textFieldRecipeName.text! as AnyObject,
                        "ImageURL": photoImageURL,
                        "AddedBy": self.userID,
                        "DateAdded": "\(Date())",
                        "ServingSize": Int(self.textFieldServingSize.text!)!,
                        "PrepTimeHours":  Int(self.textFieldPrepHour.text!)!,
                        "PrepTimeMinutes": Int(self.textFieldPrepMin.text!)!,
                        "CookTimeHours": Int(self.textFieldCookHour.text!)!,
                        "CookTimeMinutes": Int(self.textFieldCookMin.text!)!,
                        "Course": self.textFieldCourse.text!,
                        "Type": self.textFieldType.text!,
                        "Difficulty": Int(self.textFieldDifficulty.text!)!,
                        "AddedByAdmin": self.adminStatus] as NSMutableDictionary
                    
                    if self.adminStatus != true {
                        if self.publicStatus == true {
                            recipeValues.setValue(false, forKey: "Approved")
                        }
                    } else {
                        recipeValues.setValue(true, forKey: "Approved")
                    }
                    if (self.addRecipeIntoDatabase(recipeValues) == true) {
                        completion(true)
                        
                    }
                }
            }
        }
    }
    
    func addRecipeIntoDatabase(_ recipeValues: AnyObject) -> Bool {
        
        self.recipeDocument = ""
        
        if self.adminStatus == true || self.publicStatus == true || editCheck == true {
            
            self.recipeDocument = "Recipes"
            if editCheck == true {
                recipeRef = ref.child(recipeDocument).child(recipe.id!)
                recipeRef.updateChildValues(recipeValues as! [AnyHashable : Any])
            } else {
                recipeRef = ref.child(recipeDocument).childByAutoId()
                recipeRef.setValue(recipeValues)
            }
            
            self.recipeID = recipeRef.key
            ingredientsRef = self.ref.child(recipeDocument).child(recipeID).child("Ingredients")
            stepsRef = self.ref.child(recipeDocument).child(recipeID).child("Steps")
            ratingRef = self.ref.child(recipeDocument).child(recipeID).child("Ratings")
            reviewRef = self.ref.child(recipeDocument).child(recipeID).child("Reviews")
            
        } else {
            self.recipeDocument = "UserRecipes"
            if editCheck == true {
                self.recipeRef = ref.child(recipeDocument).child(userID).child(recipeID)
                self.recipeRef.updateChildValues(recipeValues as! [AnyHashable : Any])
            } else {
                self.recipeRef = ref.child(recipeDocument).child(userID).childByAutoId()
                self.recipeRef.setValue(recipeValues)
                self.recipeID = recipeRef.key
            }
            
            ingredientsRef = self.ref.child(recipeDocument).child(userID).child(recipeID).child("Ingredients")
            stepsRef = self.ref.child(recipeDocument).child(userID).child(recipeID).child("Steps")
            ratingRef = self.ref.child(recipeDocument).child(userID).child(recipeID).child("Ratings")
            reviewRef = self.ref.child(recipeDocument).child(userID).child(recipeID).child("Reviews")
        }
        
        ingredientsRef.removeValue()
        
        for i in 0..<self.ingredientsList.count {
            let ingredientsValues = [
                "Name": self.ingredientsList[i].name ?? "",
                "Quantity": self.ingredientsList[i].quantity ?? 0,
                "Measurement": self.ingredientsList[i].measurement ?? ""] as [String : Any]
            
            ingredientsRef.childByAutoId().setValue(ingredientsValues)
            self.ingredientsID = ingredientsRef.key
        }
        
        stepsRef.removeValue()
        
        for j in 0..<self.stepsList.count {
            let stepsValues = [
                "Number" : self.stepsList[j].stepNo ?? 0,
                "Step": self.stepsList[j].stepDesc ?? ""] as [String : Any]
            
            stepsRef.childByAutoId().setValue(stepsValues)
            self.stepsID = stepsRef.key
            
        }
        
        for k in 0..<self.recipe.reviews.count {
            let reviewValues = [
                "RecipeRatingID" : self.recipe.reviews[k].recipeReviewID]
            reviewRef.childByAutoId().setValue(reviewValues)
        }
        
        if editCheck == false {
            let ratingValues = [
                "1" : 0,
                "2" : 0,
                "3" : 0,
                "4" : 0,
                "5" : 0]
            ratingRef.setValue(ratingValues)
        }
        return true
    }
    
    
    // MARK: Spinner View Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datasource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return datasource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if datasource == measurements {
            textFieldMeasurement.text = datasource[row]
        } else if datasource == courses {
            textFieldCourse.text = courses[row]
        } else if datasource == types {
            textFieldType.text = types[row]
        } else if datasource == difficulty {
            textFieldDifficulty.text = difficulty[row]
        } else if datasource == timeHours {
            if cookHour == true {
                textFieldCookHour.text = timeHours[row]
            } else if prepHour == true {
                textFieldPrepHour.text = timeHours[row]
            }
        } else if datasource == timeMins {
            if cookMin == true {
                textFieldCookMin.text = timeMins[row]
            } else if prepMin == true {
                textFieldPrepMin.text = timeMins[row]
            }
        }
    }
    
    // MARK: Table View Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var returnValue: Int = 0
        
        if currentStoryboardName == "Main" {
            returnValue = 1
        } else {
            if tableView == self.IngredientsAndStepsTableView {
                returnValue = 2
            }
        }
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.ingredientsTableView {
            if self.editIngredients == true {
                self.editIngredients = false
                self.textFieldIngredientName.text = ""
                self.textFieldIngredientsQuantity.text = ""
                    self.textFieldMeasurement.text = ""
                    self.buttonAddIngredients.setTitle("Add Ingredient", for: .normal)
            } else {
                self.editIngredients = true
                self.ingredientToEdit = indexPath.row
                self.textFieldIngredientName.text = self.ingredientsList[indexPath.row].name
                self.textFieldIngredientsQuantity.text = "\(self.ingredientsList[indexPath.row].quantity!)"
                self.textFieldMeasurement.text = self.ingredientsList[indexPath.row].measurement
                self.buttonAddIngredients.setTitle("Update Ingredient", for: .normal)
            }
        } else if tableView == self.stepsTableView {
            if self.editSteps == true {
                self.editSteps = false
                self.textViewSteps.text = ""
                self.buttonAddSteps.setTitle("Add Steps", for: .normal)
            } else {
                self.editSteps = true
                self.stepToEdit = indexPath.row
                self.textViewSteps.text = self.stepsList[indexPath.row].stepDesc
                self.buttonAddSteps.setTitle("Update Steps", for: .normal)
            }
        }
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete){
            if currentStoryboardName == "Ipad" {
                if tableView == self.IngredientsAndStepsTableView {
                    ingredientsList.remove(at: indexPath.row)
                    stepsList.remove(at: indexPath.row)
                }
            } else {
                if tableView == self.ingredientsTableView {
                    ingredientsList.remove(at: indexPath.row)
                    self.ingredientsTableView.reloadData()
                    
                } else if tableView == self.stepsTableView {
                    stepsList.remove(at: indexPath.row)
                    self.stepsTableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        returnValue = 0
        
        if currentStoryboardName == "Main" {
            if tableView == self.ingredientsTableView {
                returnValue = ingredientsList.count
            } else if tableView == self.stepsTableView {
                returnValue = stepsList.count
            }
        } else {
            if tableView == self.IngredientsAndStepsTableView {
                if section == 0 {
                    returnValue = ingredientsList.count
                } else if section == 1 {
                    returnValue = stepsList.count
                }
            }
        }
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = nil
        
        if currentStoryboardName == "Ipad" {
            
            if tableView == self.IngredientsAndStepsTableView {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsAndStepsToAddCell", for: indexPath)
                
                if indexPath.section == 0 {
                    cell?.textLabel?.text = ingredientsList[indexPath.row].name
                    cell?.detailTextLabel?.text = "\(ingredientsList[indexPath.row].quantity!)  \( ingredientsList[indexPath.row].measurement!)"
                    
                } else if indexPath.section == 1 {
                    cell?.textLabel?.text = (stepsList[indexPath.row].stepNo).map{ String($0)}
                    cell?.detailTextLabel?.text = stepsList[indexPath.row].stepDesc
                }
            }
        } else {
            if tableView == self.ingredientsTableView {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "ingredientsCell", for: indexPath)
                cell?.textLabel?.text = ingredientsList[indexPath.row].name
                cell?.detailTextLabel?.text = "\(ingredientsList[indexPath.row].quantity!)  \( ingredientsList[indexPath.row].measurement!)"
                
            } else if tableView == self.stepsTableView {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "stepsCell", for: indexPath)
                cell?.textLabel?.text = (stepsList[indexPath.row].stepNo).map{ String($0)}
                cell?.detailTextLabel?.text = stepsList[indexPath.row].stepDesc
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var returnValue: String = ""
        
        if currentStoryboardName == "Main" {
            if tableView == self.ingredientsTableView {
                returnValue = "Ingredients To Add"
            } else if tableView == self.stepsTableView {
                returnValue = "Steps To Add"
            }
        } else {
            if tableView == self.IngredientsAndStepsTableView {
                if section == 0 {
                    returnValue = "Ingredients To Add"
                } else if section == 1 {
                    returnValue = "Steps To Add"
                }
            }
        }
        return returnValue
    }
    // MARK: Misc Methods
    
    // ToolBar
    
    func setUpToolBar(){
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.default
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.black
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        label.font = UIFont(name: "Helvetica", size: 12)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.text = "Pick an Option"
        label.textAlignment = NSTextAlignment.center
        let textBtn = UIBarButtonItem(customView: label)
        toolBar.setItems([flexSpace,textBtn,flexSpace,doneButton], animated: true)
        textFieldMeasurement.inputAccessoryView = toolBar
        textFieldCourse.inputAccessoryView = toolBar
        textFieldDifficulty.inputAccessoryView = toolBar
        textFieldType.inputAccessoryView = toolBar
        textFieldCookHour.inputAccessoryView = toolBar
        textFieldCookMin.inputAccessoryView = toolBar
        textFieldPrepHour.inputAccessoryView = toolBar
        textFieldPrepMin.inputAccessoryView = toolBar
    }
    
    func donePressed(sender: UIBarButtonItem) {
        textFieldMeasurement.resignFirstResponder()
        textFieldType.resignFirstResponder()
        textFieldDifficulty.resignFirstResponder()
        textFieldCourse.resignFirstResponder()
        textFieldCookHour.resignFirstResponder()
        textFieldCookMin.resignFirstResponder()
        textFieldPrepHour.resignFirstResponder()
        textFieldPrepMin.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func myTargetFunction(textField: UITextField) {
        if textField == textFieldMeasurement {
            datasource = measurements
        } else if textField == textFieldCourse {
            datasource = courses
        } else if textField == textFieldType {
            datasource = types
        } else if textField == textFieldDifficulty {
            datasource = difficulty
        } else if textField == textFieldCookHour {
            datasource = timeHours
            resetBools()
            cookHour = true
        } else if textField == textFieldCookMin {
            datasource = timeMins
            resetBools()
            cookMin = true
        } else if textField == textFieldPrepHour {
            datasource = timeHours
            resetBools()
            prepHour = true
            
        } else if textField == textFieldPrepMin {
            datasource = timeMins
            resetBools()
            prepMin = true
        }
        
        self.pickerView.reloadAllComponents()
        self.pickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    func checkTextFields() -> Bool {
        var result: Bool = true
        if (textFieldRecipeName.text != "" && textFieldServingSize.text != "" && textFieldCookHour.text != "" && textFieldCookMin.text != "" && textFieldPrepHour.text != "" && textFieldPrepMin.text != "" && textFieldCourse.text != "" && textFieldType.text != "" && textFieldDifficulty.text != "") {
            result = false
        }
        return result
    }
    
    func resetBools() {
        cookHour = false
        cookMin = false
        prepHour = false
        prepMin = false
    }
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func RBSquareImageTo(image: UIImage, size: CGSize) -> UIImage {
        return RBResizeImage(image: RBSquareImage(image: image), targetSize: size)
    }
    
    func RBSquareImage(image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var edge: CGFloat = 0.0
        
        if (originalWidth > originalHeight) {
            // landscape
            edge = originalHeight
            x = (originalWidth - edge) / 2.0
            y = 0.0
            
        } else if (originalHeight > originalWidth) {
            // portrait
            edge = originalWidth
            x = 0.0
            y = (originalHeight - originalWidth) / 2.0
        } else {
            // square
            edge = originalWidth
        }
        
        let cropSquare = CGRect(x:x, y:y, width:edge, height:edge)
        let imageRef = image.cgImage!.cropping(to: cropSquare);
        
        
        return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
    
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0, width:newSize.width, height:newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
