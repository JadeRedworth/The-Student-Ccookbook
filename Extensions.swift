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

extension AddRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled Picker")
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

extension String {
    
    func storeImage(image: UIImage!, completed: @escaping (_ result: String) -> Void) {
        
        let uniqueImageName = UUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("recipe_images").child("\(uniqueImageName).jpeg")
        
        if let storedImage = image, let uploadData = UIImageJPEGRepresentation(storedImage, 0.1) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                } else if let photoImageURL = metadata?.downloadURL()?.absoluteString {
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
    func fetchFavourites(refName: String, queryKey: String, queryValue: String, ref: FIRDatabaseReference, completion: @escaping (_ result: [String]) -> Void) {
        var recipeIDs = [String]()
        let favouritesRef = ref.child(refName).child(queryValue)
        favouritesRef.observe(.value, with: { (snapshot) in
            recipeIDs.removeAll()
            let favourtiesEnumerator = snapshot.childSnapshot(forPath: "Favourites").children
            while let favItem = favourtiesEnumerator.nextObject() as? FIRDataSnapshot {
                recipeIDs.append(favItem.childSnapshot(forPath: "RecipeID").value as! String)
            }
            completion(recipeIDs)
        })
    }
    
    func fetchUserReviews(refName: String, queryKey: String, ref: FIRDatabaseReference, completion: @escaping (_ result: [String]) -> Void){
        var reviewIDs = [String]()
        let userReviewRef = ref.child(refName).child(queryKey)
        userReviewRef.observe(.value, with: { (snapshot) in
            let reviewsEnumerator = snapshot.childSnapshot(forPath: "Reviews").children
            while let reviewsItem = reviewsEnumerator.nextObject() as? FIRDataSnapshot {
                reviewIDs.append(reviewsItem.childSnapshot(forPath: "RecipeReviewID").value as! String)
            }
            completion(reviewIDs)
        })
    }
    
    func fetchRecipeReviews(refName: String, queryKey: String, ref: FIRDatabaseReference, completion: @escaping (_ result: [String]) -> Void){
        var reviewIDs = [String]()
        let recipeReviewRef = ref.child(refName).child(queryKey)
        recipeReviewRef.observe(.value, with: { (snapshot) in
            let reviewsEnumerator = snapshot.childSnapshot(forPath: "Reviews").children
            while let reviewsItem = reviewsEnumerator.nextObject() as? FIRDataSnapshot {
                reviewIDs.append(reviewsItem.childSnapshot(forPath: "RecipeRatingID").value as! String)
            }
            completion(reviewIDs)
        })
    }
}

extension Array where Element: User {
    
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
                users.email = userDict["Email"] as? String ?? ""
                users.age = userDict["Age"] as? Int
                users.gender = userDict["Gender"] as? String ?? ""
                users.location = userDict["Location"] as? String ?? ""
                users.profilePicURL = userDict["ProfileImageURL"] as? String ?? ""
                
                userList.append(users)
            }
            completion(userList)
        })
    }
}

extension Array where Element: RecipeReviews {
    
    func fetchRecipeReviews(refName: String, queryKey: String, queryValue: String, ref: FIRDatabaseReference, completion: @escaping (_ result: [RecipeReviews]) -> Void){
        
        let recipeReviewRef = ref.child(refName)
        query = recipeReviewRef.child(queryValue)
        dataEventType = .value
        
        var recipeReviewList = [RecipeReviews]()

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

extension Array where Element: Recipes {
    
    func fetchRecipes(refName: String, queryKey: String, queryValue: AnyObject, recipeToSearch: String, ref: FIRDatabaseReference, completion: @escaping (_ result: [Recipes]) -> Void) {
        
        var recipeList = [Recipes]()
        let recipeRef = ref.child(refName)
        
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
                query = recipeRef.child(queryValue as! String)
                dataEventType = .childAdded
            } else {
                query = recipeRef
                dataEventType = .childAdded
            }
        }
        
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
        
        query.observe(dataEventType, with: { (snapshot) in
            
            if let recipeDict = snapshot.value as? [String: AnyObject] {
                
                let recipes = Recipes()
                let ratingsEnumerator = snapshot.childSnapshot(forPath: "Ratings").childSnapshot(forPath: "Values").children
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
                while let ratingItem = ratingsEnumerator.nextObject() as? FIRDataSnapshot {
                    value = (ratingItem.value as? Int)!
                    key = Int(ratingItem.key)!
                    rating += key*value
                }
                averageRating = rating/5
                recipes.rating = averageRating
                
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
                    recipeList.append(recipes)
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
    
    func makeImageCircle(){
        self.layer.cornerRadius = self.frame.width/2
        self.layer.masksToBounds = true
    }
    
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
    
    func loadImageWithCacheWithUrlString(_ urlString: String) {
        
        // Check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            
            // downloading hit an error so we need to return out
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    
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

extension UIColor{
    func HexToColor(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        let scanner: Scanner = Scanner(string: hexStr)
        scanner.charactersToBeSkipped = CharacterSet.init(charactersIn: "#")
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
}

extension UIViewController {
    
    func dismissKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RecipeTableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}



