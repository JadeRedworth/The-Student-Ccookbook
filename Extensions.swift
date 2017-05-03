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

extension String {
    
    func storeImage(image: UIImage!, completed: @escaping (_ result: String) -> Void) {

        let uniqueImageName = UUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("recipe_images").child("\(uniqueImageName).jpeg")
        
        if let storedImage = image, let uploadData = UIImageJPEGRepresentation(storedImage, 0.1) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                print(metadata!)
                if error != nil {
                    print(error!)
                    return
                } else if let photoImageURL = metadata?.downloadURL()?.absoluteString {
                    print(photoImageURL)
                    completed(photoImageURL)
                }
            })
        }
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
            print(snapshot)
            
            if let userDict = snapshot.value as? [String: AnyObject] {
                //print(recipeDict)
                
                let users = User()
                users.userID = snapshot.key
                users.admin = userDict["Admin"] as? Bool
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

extension Array where Element: Recipes {
    
    func fetchRecipes(refName: String, queryKey: String, queryValue: AnyObject, ref: FIRDatabaseReference, completion: @escaping (_ result: [Recipes]) -> Void) {
        
        var recipeList = [Recipes]()
        let recipeRef = ref.child(refName)
        
        if refName == "Recipes" {
            if (queryValue is Bool) {
                query = recipeRef.queryOrdered(byChild: queryKey).queryEqual(toValue: queryValue)
                dataEventType = .childAdded
                
            } else if (queryValue is String) {
                query = recipeRef.child(queryValue as! String)
            }
            
            if queryKey.isEmpty {
                dataEventType = .value
            } else {
                dataEventType = .childAdded
            }
            
        } else if refName == "UserRecipes" {
            query = recipeRef.child(queryValue as! String)
            dataEventType = .childAdded
        }
        
        recipeList.fillData(query: query, dataEventType: dataEventType!) {
            (result: [Recipes]) in
            recipeList = result
            completion(recipeList)
            
        }
        if recipeList.isEmpty {
            completion(recipeList)
        }
    }
    
    func fillData(query: FIRDatabaseQuery, dataEventType: FIRDataEventType, completion: @escaping (_ result: [Recipes]) -> Void) {
        
        var recipeList = [Recipes]()
    
        query.observe(dataEventType, with: { (snapshot) in
            //print(snapshot)
            //print(snapshot.value!)
            
            if let recipeDict = snapshot.value as? [String: AnyObject] {
                //print(recipeDict)
                
                let recipes = Recipes()
                let ingredientsEnumerator = snapshot.childSnapshot(forPath: "Ingredients").children
                let stepsEnumerator = snapshot.childSnapshot(forPath: "Steps").children
                
                recipes.id = snapshot.key
                recipes.addedBy = recipeDict["AddedBy"] as? String ?? ""
                recipes.approved = recipeDict["Approved"] as? Bool
                recipes.addedByAdmin = recipeDict["AddedByAdmin"] as? Bool
                recipes.cookTimeHour = recipeDict["CookTimeHours"] as? Int
                recipes.cookTimeMinute = recipeDict["CookTimeMinutes"] as? Int
                recipes.course = recipeDict["Course"] as? String ?? ""
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
                recipeList.append(recipes)
            }
            //print("Not reached")
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
}
