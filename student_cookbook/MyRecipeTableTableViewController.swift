//
//  RecipeTableViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 06/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class MyRecipeTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var cellId = "RecipeCell"
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    
    var myRecipeList = [Recipes]()
    var favRecipeList = [Recipes]()
    
    var selectedFavouritesRecipeList = [Recipes]()
    var filteredFavouritesRecipeList = [Recipes]()
    
    var selectedMyRecipeList = [Recipes]()
    var filteredMyRecipeList = [Recipes]()
    
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    
    var recipesID = [String]()
    
    private let searchController = UISearchController(searchResultsController: nil)

    @IBAction func buttonLogout(_ sender: Any) {
        handleLogout()
    }

    var ingredientsID: String!
    var stepsID: String!
    var valueToPass:String!
    var uid: String!
    var editCheck: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "RecipeTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: cellId)
        
        ref = FIRDatabase.database().reference()
        
        uid = FIRAuth.auth()?.currentUser?.uid
        
        if uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        getMyRecipes()
        getMyFavourites()
        
        self.setupSearchController()
        self.tableView.reloadData()
    }
    
    func reloadData() {
        getMyRecipes()
        getMyFavourites()
        self.tableView.reloadData()
    }
    
    func getMyRecipes() {
        myRecipeList.fetchRecipes(refName: "UserRecipes", queryKey: "", queryValue: uid! as AnyObject, ref: ref) {
            (result: [Recipes]) in
            print(result)
            self.myRecipeList = result
            self.filteredMyRecipeList = Recipes.generateModelArray(self.myRecipeList)
            self.tableView.reloadData()
        }
        
        myRecipeList.fetchRecipes(refName: "Recipes", queryKey:  "AddedBy", queryValue: uid! as AnyObject, ref: ref) {
            (result: [Recipes]) in
            print(result)
            self.myRecipeList = result
            self.filteredMyRecipeList = Recipes.generateModelArray(self.myRecipeList)
            self.tableView.reloadData()
        }
    }
    
    func getMyFavourites() {
        fetchFavourites() {
            result in
            if result {
                for i in 0..<self.recipesID.count {
                    self.favRecipeList.fetchRecipes(refName: "Recipes", queryKey: "", queryValue: self.recipesID[i] as AnyObject, ref: self.ref) {
                         (result: [Recipes]) in
                        self.favRecipeList += result
                        self.filteredFavouritesRecipeList = Recipes.generateModelArray(self.favRecipeList)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func fetchFavourites(completion: @escaping (_ result: Bool) -> Void) {
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
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All","Breakfast","Lunch","Dinner", "Dessert", "Snack"]
        searchController.searchBar.delegate = self as UISearchBarDelegate
    }
    
    func filterSearchController(searchBar: UISearchBar){
        guard let scopeString = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] else { return }
        let selectedCourse = Recipes.Course(rawValue: scopeString) ?? .All
        let searchText = searchBar.text ?? ""
        
        filteredMyRecipeList = myRecipeList.filter { recipe in
            let matchingCourse = (selectedCourse == .All) || (recipe.course == selectedCourse)
            let matchingText = (recipe.name?.lowercased().contains(searchText.lowercased()))! || searchText.lowercased().characters.count == 0
            return matchingCourse && matchingText
        }
        
        filteredFavouritesRecipeList = favRecipeList.filter { recipe in
            let matchingCourse = (selectedCourse == .All) || (recipe.course == selectedCourse)
            let matchingText = (recipe.name?.lowercased().contains(searchText.lowercased()))! || searchText.lowercased().characters.count == 0
            return matchingCourse && matchingText
        }
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchBar: searchController.searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterSearchController(searchBar: searchBar)
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
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnValue: String = ""
        if (section == 0) {
            returnValue = "My Recipes"
        } else if (section == 1) {
            returnValue = "My Favourites"
        }
        return returnValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var returnValue: Int = 0
        if (section == 0) {
            returnValue = self.filteredMyRecipeList.count
        } else if (section == 1) {
            returnValue = self.filteredFavouritesRecipeList.count
        }
        return returnValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RecipeTableViewCell
    
        if (indexPath.section == 0){
            
            let recipe = filteredMyRecipeList[indexPath.row]
            cell.labelRecipeName.text = recipe.name
            cell.labelRecipeAddedBy.text = "@: \(recipe.addedBy!)"
        
            if recipe.imageURL != nil {
                if let recipeImageURL = recipe.imageURL {
                    cell.recipeImageView.loadImageWithCacheWithUrlString(recipeImageURL)
                }
            }
        } else if (indexPath.section == 1){
            
            let recipe = filteredFavouritesRecipeList[indexPath.row]
            cell.labelRecipeName.text = recipe.name
            cell.labelRecipeAddedBy.text = "@: \(recipe.addedBy!)"
            
            if recipe.imageURL != nil {
                if let recipeImageURL = recipe.imageURL {
                    cell.recipeImageView.loadImageWithCacheWithUrlString(recipeImageURL)
                }
            }
        }
        
        return cell
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "MyRecipeDetailSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nav = segue.destination as! UINavigationController
        var selectedRow = Recipes()
        let indexPath = (sender as! NSIndexPath)
        
        if segue.identifier == "MyRecipeDetailSegue" {
            
            let controller = nav.topViewController as! RecipeDetailViewController
            
            if (indexPath.section == 0){
                selectedRow = filteredMyRecipeList[indexPath.row]
            } else if (indexPath.section == 1){
                selectedRow = filteredFavouritesRecipeList[indexPath.row]
            }
            
            controller.recipe = selectedRow
            
        } else if segue.identifier == "EditRecipeSegue" {
            
            let editController = nav.topViewController as! AddRecipeViewController
            
            if (indexPath.section == 0) {
                selectedRow = filteredMyRecipeList[indexPath.row]
            } else if (indexPath.section == 1){
                selectedRow = filteredFavouritesRecipeList[indexPath.row]
            }
            editController.recipes = selectedRow
            editController.editCheck = self.editCheck
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit Recipe") { action, index in
            self.editCheck = true
            self.performSegue(withIdentifier: "EditRecipeSegue", sender: indexPath)
        }
        edit.backgroundColor = UIColor.yellow
        
        let favorites = UITableViewRowAction(style: .normal, title: "Add To Favourites") { action, index in
            let userRef = self.ref.child("Users").child(self.uid).child("Favourites").childByAutoId()
            let favValue = ["RecipeID": self.filteredMyRecipeList[indexPath.row].id]
            userRef.setValue(favValue)
            self.showAlert(title: "Success", message: "Recipe has been added to Favourites")
            
        }
        favorites.backgroundColor = UIColor.blue
        
        return [edit, favorites]
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete){
            let recipeToRemove = self.filteredMyRecipeList[indexPath.row].id
            
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
            filteredMyRecipeList.remove(at: indexPath.row)
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
