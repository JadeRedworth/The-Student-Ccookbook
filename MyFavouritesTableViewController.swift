//
//  MyFavouritesTableViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 27/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

enum electedScope:Int {
    case all = 0
    case breakfast = 1
    case lunch = 2
    case dinner = 3
    case dessert = 4
    case snack = 5
}

class MyFavouritesTableViewController: UITableViewController, UISearchBarDelegate {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    
    var recipeList = [Recipes]()
    var selectedRecipeList = [Recipes]()
    var filteredRecipeList = [Recipes]()
    
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    
    @IBAction func buttonLogout(_ sender: Any) {
        handleLogout()
    }
    
    var ingredientsID: String!
    var stepsID: String!
    var valueToPass:String!
    var uid: String!
    var editCheck: Bool = false
    var recipesID = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "RecipeTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "RecipeCell")
        
        ref = FIRDatabase.database().reference()
        
        uid = FIRAuth.auth()?.currentUser?.uid
        
        if uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        getFavourites() {
            result in
            if result {
                for i in 0..<self.recipesID.count {
                    self.recipeList.fetchRecipes(refName: "Recipes", queryKey: "", queryValue: self.recipesID[i] as AnyObject, ref: self.ref) {
                        (result: [Recipes]) in
                        self.recipeList += result
                        self.filteredRecipeList = Recipes.generateModelArray(self.recipeList)
                        self.tableView.reloadData()
                    }
                }
            }
        }
        self.searchBarSetup()
        self.tableView.reloadData()
    }
    
    func getFavourites(completion: @escaping (_ result: Bool) -> Void) {
        let favouritesRef = self.ref.child("Users").child(uid)
        favouritesRef.observe(.value, with: { (snapshot) in
            print(snapshot)
            let favourtiesEnumerator = snapshot.childSnapshot(forPath: "Favourites").children
            while let favItem = favourtiesEnumerator.nextObject() as? FIRDataSnapshot {
                self.recipesID.append(favItem.childSnapshot(forPath: "RecipeID").value as! String)
            }
            completion(true)
        })
    }
    
    func handleLogout() {
        try! FIRAuth.auth()!.signOut()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
    
    
    func searchBarSetup() {
        let searchBar = UISearchBar(frame: CGRect(x:0,y:0,width:(UIScreen.main.bounds.width),height:70))
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["All", "Breakfast","Lunch","Dinner", "Dessert", "Snack"]
        searchBar.selectedScopeButtonIndex = 0
        searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar
    }
    
    // MARK: - search bar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredRecipeList = recipeList
            self.tableView.reloadData()
        } else {
            filterTableView(searchBar.selectedScopeButtonIndex, text: searchText)
        }
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 0 {
            filteredRecipeList = recipeList
            self.tableView.reloadData()
            
        } else if selectedScope == 1 {
            filteredRecipeList = recipeList.filter({ (breakfast) -> Bool in
                return (breakfast.course?.contains("Breakfast"))!
            })
            self.tableView.reloadData()
            selectedRecipeList = filteredRecipeList
            
        } else if selectedScope == 2 {
            filteredRecipeList = recipeList.filter({ (lunch) -> Bool in
                return (lunch.course?.contains("Lunch"))!
            })
            self.tableView.reloadData()
            selectedRecipeList = filteredRecipeList
            
        } else if selectedScope == 3 {
            filteredRecipeList = recipeList.filter({ (dinner) -> Bool in
                return (dinner.course?.contains("Dinner"))!
            })
            self.tableView.reloadData()
            selectedRecipeList = filteredRecipeList
            
        } else if selectedScope == 4 {
            filteredRecipeList = recipeList.filter({ (dessert) -> Bool in
                return (dessert.course?.contains("Dessert"))!
            })
            self.tableView.reloadData()
            selectedRecipeList = filteredRecipeList
            
        } else if selectedScope == 5 {
            filteredRecipeList = recipeList.filter({ (snack) -> Bool in
                return (snack.course?.contains("Snack"))!
            })
            self.tableView.reloadData()
            selectedRecipeList = filteredRecipeList
        }
    }
    
    func filterTableView(_ ind: Int, text: String) {
        switch ind {
        case selectedScope.all.rawValue:
            filteredRecipeList = recipeList.filter({ (recipes) -> Bool in
                return (recipes.name?.lowercased().contains(text.lowercased()))! ||
                    (recipes.type?.lowercased().contains(text.lowercased()))!
            })
            self.tableView.reloadData()
            break
            
        case selectedScope.breakfast.rawValue:
            filteredRecipeList = selectedRecipeList.filter({ (breakfast) -> Bool in
                return (breakfast.name?.lowercased().contains(text.lowercased()))! ||
                    (breakfast.type?.lowercased().contains(text.lowercased()))!
            })
            self.tableView.reloadData()
            break
            
        case selectedScope.lunch.rawValue:
            filteredRecipeList = selectedRecipeList.filter({ (lunch) -> Bool in
                return (lunch.name?.lowercased().contains(text.lowercased()))! ||
                    (lunch.type?.lowercased().contains(text.lowercased()))!
            })
            self.tableView.reloadData()
            break
            
        case selectedScope.dinner.rawValue:
            filteredRecipeList = selectedRecipeList.filter({ (dinner) -> Bool in
                return (dinner.name?.lowercased().contains(text.lowercased()))! ||
                    (dinner.type?.lowercased().contains(text.lowercased()))!
            })
            self.tableView.reloadData()
            break
            
        case selectedScope.dessert.rawValue:
            filteredRecipeList = selectedRecipeList.filter({ (dessert) -> Bool in
                return (dessert.name?.lowercased().contains(text.lowercased()))! ||
                    (dessert.type?.lowercased().contains(text.lowercased()))!
            })
            self.tableView.reloadData()
            break
            
        case selectedScope.snack.rawValue:
            filteredRecipeList = selectedRecipeList.filter({ (snack) -> Bool in
                return (snack.name?.lowercased().contains(text.lowercased()))! ||
                    (snack.type?.lowercased().contains(text.lowercased()))!
            })
            self.tableView.reloadData()
            break
            
        default:
            print("No Recipes")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Return ID's delegate
    
    func returnStepID(_ stepsID: String) {
        self.stepsID = stepsID
        tableView.reloadData()
    }
    
    func returnIngredientsID(_ ingredientsID: String) {
        self.ingredientsID = ingredientsID
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.filteredRecipeList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeTableViewCell
        
        let recipe = filteredRecipeList[indexPath.row]
        cell.labelRecipeName.text = recipe.name
        cell.labelRecipeAddedBy.text = "@: \(recipe.addedBy!)"
        
        if recipe.imageURL != nil {
            if let recipeImageURL = recipe.imageURL {
                
                cell.recipeImageView.loadImageWithCacheWithUrlString(recipeImageURL)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "MyFavouritesDetailSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nav = segue.destination as! UINavigationController
        if segue.identifier == "MyFavouritesDetailSegue" {
            let controller = nav.topViewController as! RecipeDetailViewController
            
            let indexPath = (sender as! NSIndexPath)
            let selectedRow = filteredRecipeList[indexPath.row]
            controller.recipe = selectedRow
            
        } else if segue.identifier == "EditRecipeSegue" {
            let controller = nav.topViewController as! AddRecipeViewController
            
            let indexPath = (sender as! NSIndexPath)
            let selectedRow = filteredRecipeList[indexPath.row]
            controller.recipes = selectedRow
            controller.editCheck = self.editCheck
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit Recipe") { action, index in
            self.editCheck = true
            self.performSegue(withIdentifier: "EditRecipeSegue", sender: self)
        }
        edit.backgroundColor = UIColor.yellow
        
        let favorites = UITableViewRowAction(style: .normal, title: "Add To Favourites") { action, index in
            let userRef = self.ref.child("Users").child(self.uid).child("Favorites").child(self.filteredRecipeList[indexPath.row].id!)
            userRef.setValue(self.filteredRecipeList[indexPath.row].name)
            self.showAlert(title: "Success", message: "Recipe has been added to Favourites")
            
        }
        favorites.backgroundColor = UIColor.blue
        
        return [edit, favorites]
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete){
            let recipeToRemove = self.filteredRecipeList[indexPath.row].id
            
            ref.child("UserRecipes").child(uid).child(recipeToRemove!).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to Delete Recipes", error as Any)
                    self.showAlert(title: "Error", message: "Failed to delete Recipe")
                    return
                }
            })
            ref.child("Recipes").child(recipeToRemove!).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to Delete Recipes", error as Any)
                    self.showAlert(title: "Error", message: "Failed to delete Recipe")
                    return
                }
            })
            filteredRecipeList.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
    }
}
