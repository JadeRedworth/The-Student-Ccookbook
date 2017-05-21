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

class MyFavouritesTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var cellId = "RecipeCell"
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    
    var recipe = Recipes()
    
    var favRecipeList = [Recipes]()
    
    var filteredFavouritesRecipeList = [Recipes]()
    
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    var selectedRecipe = Recipes()
    
    var userList = [User]()
    
    var recipesID = [String]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    var ingredientsID: String!
    var stepsID: String!
    var valueToPass:String!
    var uid: String!
    
    var editCheck: Bool = false
    var deleteCheck: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "RecipeTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: cellId)
        
        ref = FIRDatabase.database().reference()
        
        uid = FIRAuth.auth()?.currentUser?.uid
        
        if uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            reloadData()
            
            self.setupSearchController()
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
    }
    
    func reloadData() {
        self.filteredFavouritesRecipeList.removeAll()
        self.recipesID.removeAll()
        getMyFavourites(completion: {
            result in
            if result {
                for i in 0..<self.recipesID.count {
                    self.favRecipeList.fetchRecipes(refName: "Recipes", queryKey: "", queryValue: self.recipesID[i] as AnyObject, recipeToSearch: "", ref: self.ref) {
                        (result: [Recipes]) in
                        self.filteredFavouritesRecipeList += Recipes.generateModelArray(result)
                        self.tableView.reloadData()
                    }
                }
            }
        })
        self.tableView.reloadData()
    }
    
    func getMyFavourites(completion: @escaping (Bool) -> ()) {
        self.tableView.reloadData()
        self.recipesID.fetchFavourites(refName: "Users", queryKey: "", queryValue: uid, ref: ref) {
            (result: [String]) in
            self.recipesID = result
            if self.recipesID.isEmpty {
            } else {
                completion(true)
            }
        }
    }
    
    func fetchUserWhoAddedRecipe(completion: @escaping (Bool) -> ()) {
        userList.fetchUsers(refName: "Users", queryKey: self.recipe.addedBy!, queryValue: "" as AnyObject, ref: ref) {
            (result: [User]) in
            if result.isEmpty {
                self.userList = []
            } else {
                self.userList = result
                completion(true)
            }
        }
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
        searchController.searchBar.scopeButtonTitles = ["All","Breakfast","Lunch","Dinner", "Dessert"]
        searchController.searchBar.delegate = self as UISearchBarDelegate
    }
    
    func filterSearchController(searchBar: UISearchBar){
        guard let scopeString = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] else { return }
        let selectedCourse = Recipes.Course(rawValue: scopeString) ?? .All
        let searchText = searchBar.text ?? ""
        
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.filteredFavouritesRecipeList.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RecipeTableViewCell
        
        recipe = filteredFavouritesRecipeList[indexPath.row]
        
        cell.labelRecipeName.text = recipe.name
        
        fetchUserWhoAddedRecipe(completion: {
            result in
            if result {
                cell.labelRecipeAddedBy?.text = "Added by: \(self.userList[0].firstName!) \(self.userList[0].lastName!)"
                cell.userImageView.loadImageWithCacheWithUrlString(self.userList[0].profilePicURL!)
                cell.userImageView.makeImageCircle()
            }
        })
        
        var starRating: String = ""
        starRating = starRating.getStarRating(rating: "\(recipe.averageRating!)")
        cell.labelRating.text = starRating
        
        if recipe.imageURL != nil {
            if let recipeImageURL = recipe.imageURL {
                cell.recipeImageView?.loadImageWithCacheWithUrlString(recipeImageURL)
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
        let controller = nav.topViewController as! RecipeDetailViewController
        
        let indexPath = (sender as! NSIndexPath)
        var selectedRow = Recipes()
        selectedRow = filteredFavouritesRecipeList[indexPath.row]
        controller.recipeId = selectedRow.id!
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 247
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete){
            
            self.selectedRecipe = self.filteredFavouritesRecipeList[indexPath.row]
            let alert = UIAlertController(title: "❗️", message: "Are you sure you want to remove this recipe from favourites?", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                let removeFavouriteRef = self.ref.child("Users").child(self.uid).child("Favourites")
                query = removeFavouriteRef.queryOrdered(byChild: "RecipeID").queryEqual(toValue: self.selectedRecipe.id)
                query.observe(.value, with: { (snapshot) in
                    if snapshot.exists() {
                        let favouritesEnumerator = snapshot.children
                        while let favouritesItem = favouritesEnumerator.nextObject() as? FIRDataSnapshot {
                            let key = favouritesItem.key
                            removeFavouriteRef.child(key).removeValue()
                            self.filteredFavouritesRecipeList.remove(at: indexPath.row)
                            self.tableView.reloadData()
                        }
                    } else {
                        print("No snapshot")
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
    }
}
