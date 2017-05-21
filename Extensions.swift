//
//  Extensions.swift
//  student_cookbook
//
//  Created by Jade Redworth on 06/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

let imageCache = NSCache<AnyObject, AnyObject>()
var query = FIRDatabaseQuery()
var dataEventType: FIRDataEventType!

// All extensions are used to reduce duplicate code and allow all asynchronous taks to be completed within 
// a completion block. As all Firebase database queries are done asynchronously, completion blocks allow for the
// deisre results to be obtained before the functions return the given value

extension AddRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Allows the user to pick the size of the image within a give frame. This was used to obtain the correct
    // size image for uploading to Firebase Storage
    func handleSelectImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedImageFromPicker = editedImage as! UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginaImage"]{
            selectedImageFromPicker = originalImage as! UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            photoImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedImageFromPicker = editedImage as! UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginaImage"]{
            selectedImageFromPicker = originalImage as! UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profilePicture.image = selectedImage
            profilePicture.makeImageCircle()
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension EditUserDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedImageFromPicker = editedImage as! UIImage
        } else if let originalImage = info["UIImagePickerControllerOriginaImage"]{
            selectedImageFromPicker = originalImage as! UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profilePicture.image = selectedImage
            profilePicture.makeImageCircle()
        }
        
        dismiss(animated: true, completion: nil)
    }
}


extension String {
    
    func storeImage(image: UIImage!, completed: @escaping (_ result: String) -> Void) {
        
        let uniqueImageName = UUID().uuidString
        // Upload the photo to the firebase storage
        let storageRef = FIRStorage.storage().reference().child("recipe_images").child("\(uniqueImageName).jpeg")
        
        if let storedImage = image, let uploadData = UIImageJPEGRepresentation(storedImage, 0.1) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                } else if let photoImageURL = metadata?.downloadURL()?.absoluteString {
                    // If the image was successfully uploaded into Firebase Storage, the associated imageURL can be returned.
                    completed(photoImageURL)
                }
            })
        }
    }
    
    func getStarRating(rating: String) -> String { 
        
        var ratingString = ""
        
        switch (rating) {
            
        case "0":
        ratingString = "☆☆☆☆☆"
            
        case "1":
            ratingString = "★☆☆☆☆"
            break
        case "2":
            ratingString = "★★☆☆☆"
            break
        case "3":
            ratingString = "★★★☆☆"
            break
        case "4":
            ratingString = "★★★★☆"
            break
        case "5":
            ratingString = "★★★★★"
            break
        default:
            break
        }
        
        return ratingString
    }
}

extension Array where Element == String {
    
    // Fetches the favourite recipes of the user queried. The user id will be passed through a parameter and all
    // recipeID's in the favourites branch of Firebase are returned.
    func fetchFavourites(refName: String, queryKey: String, queryValue: String, ref: FIRDatabaseReference, completion: @escaping (_ result: [String]) -> Void) {
        var recipeIDs = [String]()
        let favouritesRef = ref.child(refName).child(queryValue)
        
        // Observe the array of recipeID's within the favourite branch
        favouritesRef.observe(.value, with: { (snapshot) in
            recipeIDs.removeAll()
            
            // Cycles through the children of the snapshot, (snapshot is the whole array returned)
            let favourtiesEnumerator = snapshot.childSnapshot(forPath: "Favourites").children
            while let favItem = favourtiesEnumerator.nextObject() as? FIRDataSnapshot {
                recipeIDs.append(favItem.childSnapshot(forPath: "RecipeID").value as! String)
            }
            completion(recipeIDs)
        })
    }
    
    // Fetches the user reviews  of the user queried. The user id will be passed through a parameter and all
    // recipeID's in the favourites branch of Firebase are returned.
    func fetchUserReviews(refName: String, queryKey: String, ref: FIRDatabaseReference, completion: @escaping (_ result: [String]) -> Void){
        var reviewIDs = [String]()
        let userReviewRef = ref.child(refName).child(queryKey)
        
        // Observe the array of recipeReviewID's within the RecipeReviews branch
        userReviewRef.observe(.value, with: { (snapshot) in
            print(snapshot)
            let reviewsEnumerator = snapshot.childSnapshot(forPath: "Reviews").children
            reviewIDs.removeAll()
            
            // Cycles through the children of the snapshot, (snapshot is the whole array returned)
            while let reviewsItem = reviewsEnumerator.nextObject() as? FIRDataSnapshot {
                print(reviewsItem)
                let key = reviewsItem.childSnapshot(forPath: "RecipeReviewID").value
                reviewIDs.append(key as! String)
            }
            completion(reviewIDs)
        })
    }
    
    // Fetches the reviews associated to the recipeID passed through as a parameter.
    func fetchRecipeReviews(refName: String, queryKey: String, ref: FIRDatabaseReference, completion: @escaping (_ result: [String]) -> Void){
        var reviewIDs = [String]()
        let recipeReviewRef = ref.child(refName).child(queryKey)
        
        // Observe the array of recipeReviewID's within the RecipeReviews branch
        recipeReviewRef.observe(.value, with: { (snapshot) in
            let reviewsEnumerator = snapshot.childSnapshot(forPath: "Reviews").children
            reviewIDs.removeAll()
            
            // Cycles through the children of the snapshot, (snapshot is the whole array returned)
            while let reviewsItem = reviewsEnumerator.nextObject() as? FIRDataSnapshot {
                let key = reviewsItem.childSnapshot(forPath: "RecipeRatingID").value
                if reviewIDs.contains(key as! String){} else {
                    reviewIDs.append(key as! String)
                }
            }
            completion(reviewIDs)
        })
    }
    
    // Fetches the shopping list of the user queried. The user id will be passed through a parameter and all
    // items from the shopping lsit will be returned and appended to a list.
    func fetchShoppingList(refName: String, queryValue: String, ref: FIRDatabaseReference, completion: @escaping (_ result: [String]) -> Void){
        var shoppingList = [String]()
        let shoppingListRef = ref.child(refName).child(queryValue).child("ShoppingList")
        shoppingListRef.observe(.value, with: { (snapshot) in
            if snapshot.exists(){
                let shoppingDict: [String] = snapshot.value as! [String]
                shoppingList.removeAll()
                for i in 0..<shoppingDict.count {
                    var item: String = ""
                    item = shoppingDict[i]
                    shoppingList.append(item)
                }
                completion(shoppingList)
            } else {
                
            }
        })
    }
}

extension Array where Element: User {
    
    // Fetches the users from the 'User' branch within the Firebase Database.
    
    // Specific parameters are passed through depenedent on the desired query.
    // Check are made to identify whether to return all users or a specific user (with a passed through userID as a 
    // parameter.
    
    func fetchUsers(refName: String, queryKey: String, queryValue: AnyObject, ref: FIRDatabaseReference, completion: @escaping (_ result: [User]) -> Void) {
        
        var userList = [User]()
        let userRef = ref.child(refName)
        
        if (queryKey == ""){
            query = userRef
            dataEventType = .childAdded
        } else {
            query = userRef.child(queryKey)
            dataEventType = .value
        }
        
        query.observe(dataEventType, with: { (snapshot) in
            
            if let userDict = snapshot.value as? [String: AnyObject] {
                
                let users = User()
                users.userID = snapshot.key
                users.userType = (userDict["UserType"] as? String).map { User.UserType(rawValue: $0) }! ?? User.UserType(rawValue: "")!
                users.firstName = userDict["FirstName"] as? String ?? ""
                users.lastName = userDict["LastName"] as? String ?? ""
                users.profilePicURL = userDict["ProfileImageURL"] as? String ?? ""
                
                userList.append(users)
            }
            completion(userList)
        })
    }
}

extension Array where Element: RecipeReviews {
    
    // Fetches the recipe reviews from the 'RecipeReviews' branch within the Firebase Database.
    
    // Specific parameters are passed through depenedent on the desired query.

    func fetchRecipeReviews(refName: String, queryKey: String, queryValue: [String], ref: FIRDatabaseReference, completion: @escaping (_ result: [RecipeReviews]) -> Void){
        
        let recipeReviewRef = ref.child(refName)
        
        var recipeReviewList = [RecipeReviews]()
        
        for i in 0..<queryValue.count {
            let key:String = queryValue[i]
            query = recipeReviewRef.child(key)
            dataEventType = .value
            
            query.observe(dataEventType, with: { (snapshot) in
                if let reviewDict = snapshot.value as? [String: AnyObject] {
                    let review = RecipeReviews()
                    review.recipeID = reviewDict["RecipeID"] as? String ?? ""
                    review.userID = reviewDict["UserID"] as? String ?? ""
                    review.review = reviewDict["Review"] as? String ?? ""
                    review.ratingNo = reviewDict["Rating"] as? Int
                
                    recipeReviewList.append(review)
                }
                 completion(recipeReviewList)
            })
        }
    }
}

extension Array where Element: Messages {
    
    // Fetches the users messages from the 'AdminRecipeCommments' branch within the Firebase Database.
    
    func fecthMessages(refName: String, queryKey: String, queryValue: Bool, ref: FIRDatabaseReference, completion: @escaping (_ result: [Messages]) -> Void) {
        
        var messageList = [Messages]()
        
        let messageRef = ref.child(refName).child(queryKey)
        query = messageRef.queryOrdered(byChild: "Opened").queryEqual(toValue: queryValue)
        query.observe(.childAdded, with: { (snapshot) in
            if let messageDict = snapshot.value as? [String: AnyObject] {
                    
                let message = Messages()
                message.messageID = snapshot.key
                message.recipeID = messageDict["RecipeID"] as? String ?? ""
                message.recipeName = messageDict["RecipeName"] as? String ?? ""
                message.recipeImageURL = messageDict["RecipeImageURL"] as? String ?? ""
                message.addedBy = messageDict["AddedBy"] as? String ?? ""
                message.date = messageDict["Date"] as? String ?? ""
                message.decision = messageDict["Decision"] as? String ?? ""
                message.comment = messageDict["Comment"] as? String ?? ""
                message.opened = messageDict["Opened"] as? Bool
                
                messageList.append(message)
            }
            completion(messageList)
        })
    }
}

extension Array where Element: Recipes {
    
    // Fetches the recipes from the 'Recipes' OR 'UserRecipes' branch within the Firebase Database. This is 
    // depenedent on what value is passed through for 'refName'.
    
    // Mutlipe queries can be used within this function.
    
    // Specific parameters are passed through depenedent on the desired query.
    
    // Check are made to identify whether to return all recipes or a specific recipe (with a passed through recipeID as a parameter.
    
    
    func fetchRecipes(refName: String, queryKey: String, queryValue: AnyObject, recipeToSearch: String, ref: FIRDatabaseReference, completion: @escaping (_ result: [Recipes]) -> Void) {
        
        var recipeList = [Recipes]()
        var recipeRef = ref.child(refName)
        
        if refName == "Recipes" {
            if (queryValue is Bool) {
                query = recipeRef.queryOrdered(byChild: queryKey).queryEqual(toValue: queryValue)
                dataEventType = .childAdded
                
            } else if (queryValue is String) {
                if queryKey == "AddedBy" {
                    query = recipeRef.queryOrdered(byChild: queryKey).queryEqual(toValue: queryValue)
                } else {
                    query = recipeRef.child(queryValue as! String)
                }
            }
            
            if queryKey.isEmpty {
                dataEventType = .value
            } else {
                dataEventType = .childAdded
            }
            
        } else if refName == "UserRecipes" {
            if (queryValue is String) {
                if (queryKey != "") {
                    query = recipeRef.child(queryKey)
                    dataEventType = .childAdded
                } else {
                    query = recipeRef.child(queryValue as! String)
                    dataEventType = .childAdded
                }
            } else {
                query = recipeRef
                dataEventType = .childAdded
            }
        }
        
        // Once all the specific parameters and DatabaseReferences are setup, the method (fillData) is called.
        
        // A completion handler ensures the function is complete before the resutls are returned.
        
        recipeList.fillData(query: query, dataEventType: dataEventType!, recipeToSearch: recipeToSearch) {
            (result: [Recipes]) in
            recipeList = result
            completion(recipeList)
            
        }
    
        if recipeList.isEmpty {
            completion(recipeList)
        }
    }
    
    func fillData(query: FIRDatabaseQuery, dataEventType: FIRDataEventType, recipeToSearch: String, completion: @escaping (_ result: [Recipes]) -> Void) {
        
        var recipeList = [Recipes]()
        
        // Observe the data obtained when the database is queried.
        query.observe(dataEventType, with: { (snapshot) in
            
            
            // A dictionary is used to store the results (snapshot). These are then cycled through creating a new instance of recipes to append to the recipe list.
            if let recipeDict = snapshot.value as? [String: AnyObject] {
                
                let recipes = Recipes()
                let ratingsEnumerator = snapshot.childSnapshot(forPath: "Ratings").children
                let ingredientsEnumerator = snapshot.childSnapshot(forPath: "Ingredients").children
                let stepsEnumerator = snapshot.childSnapshot(forPath: "Steps").children
                
                recipes.id = snapshot.key
                recipes.addedBy = recipeDict["AddedBy"] as? String ?? ""
                recipes.dateAdded = recipeDict["DateAdded"] as? String ?? ""
                recipes.approved = recipeDict["Approved"] as? Bool
                recipes.addedByAdmin = recipeDict["AddedByAdmin"] as? Bool


                var rating: Int = 0
                var averageRating: Int = 0
                var key: Int = 0
                var value: Int = 0
                var t: Int = 0

                while let ratingItem = ratingsEnumerator.nextObject() as? FIRDataSnapshot {
                    
                    value = (ratingItem.value as? Int)!
                    key = Int(ratingItem.key)!
                    t+=value
                    rating += key*value
                }
                
                if rating == 0 {
                    averageRating = 0
                } else {
                    averageRating = rating/t
                }
               
                recipes.averageRating = averageRating
                
                recipes.difficulty = recipeDict["Difficulty"] as? Int
                recipes.cookTimeHour = recipeDict["CookTimeHours"] as? Int
                recipes.cookTimeMinute = recipeDict["CookTimeMinutes"] as? Int
                recipes.course = (recipeDict["Course"] as? String).map { Recipes.Course(rawValue: $0) } ?? Recipes.Course(rawValue: "")
                recipes.imageURL = recipeDict["ImageURL"] as? String ?? ""
                recipes.name = recipeDict["Name"] as? String ?? ""
                recipes.prepTimeHour = recipeDict["PrepTimeHours"] as? Int
                recipes.prepTimeMinute = recipeDict["PrepTimeMinutes"] as? Int
                recipes.servingSize = recipeDict["ServingSize"] as? Int
                recipes.type = recipeDict["Type"] as? String ?? ""
                
                // The ingredients array within the recipe must be cycled through to obtain all results similar to that above.
                var ingredientsList = [Ingredients]()
                while let ingItem = ingredientsEnumerator.nextObject() as? FIRDataSnapshot {
                    let ingredients = Ingredients()
                    ingredients.id = ingItem.key
                    ingredients.name = ingItem.childSnapshot(forPath: "Name").value as? String
                    ingredients.quantity = ingItem.childSnapshot(forPath: "Quantity").value as? Int
                    ingredients.measurement = ingItem.childSnapshot(forPath: "Measurement").value as? String ?? ""
                    ingredientsList.append(ingredients)
                }
                recipes.ingredients = ingredientsList
                
                
                // The steps array within the recipe must be cycled through to obtain all results similar to that above.
                var stepsList = [Steps]()
                while let stepItem = stepsEnumerator.nextObject() as? FIRDataSnapshot {
                    let steps = Steps()
                    steps.id = stepItem.key
                    steps.stepNo = stepItem.childSnapshot(forPath: "Number").value as? Int
                    steps.stepDesc = stepItem.childSnapshot(forPath: "Step").value as? String
                    stepsList.append(steps)
                }
                recipes.steps = stepsList
                
                if recipeToSearch.isEmpty {
                    if recipeList.contains(recipes){ } else {
                        recipeList.append(recipes)
                    }
                } else {
                    if ("\(recipes.course!)" == recipeToSearch) || (recipes.type == recipeToSearch) {
                        recipeList.append(recipes)
                    }
                }
            }
            completion(recipeList)
        })
    }
}

extension UIImageView {
    
    // Forces the UIImageView to be a perfect circle. This function can be called from any UIImageView
    func makeImageCircle(){
        self.layer.cornerRadius = self.frame.width/2
        self.layer.masksToBounds = true
    }
    
    
    // Both methods below are used within the default tableView layout.
    func setCircleSize() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.contentMode = .scaleAspectFill
    }
    
    func setRectangleSize() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.contentMode = .scaleAspectFill
    }
    
    
    // An ImageURL is passed through which is obtained from the reference in the Firebase Database.
    func loadImageWithCacheWithUrlString(_ urlString: String) {
        
        // Check to see if the image has already been cached
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // else query a new download for the image associated with the imageURL path
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    
                    // Cache the image for future use
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
}

extension UIImage {
    
    
    func scaleImageToSize(img: UIImage,size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        img.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}

extension UIViewController {
    
    // All View Controllers can call this function to dismiss the keyboard when the area around it is tapped.
    func dismissKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecipeTableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController: UITextFieldDelegate{
    
    // Adds a tool bar to all keyboards/spinners.
    
    func addToolBar(textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(UIViewController.donePressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIViewController.cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    func donePressed(){
        view.endEditing(true)
    }
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
}

extension UITextField {
    
    // Creates a white line underneath the text field.
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
