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
    
    var recipe = Recipes()
    
    var favRecipeList = [Recipes]()
    var myPublicRecipeList = [Recipes]()
    var myPrivateRecipeList = [Recipes]()

    var filteredFavouritesRecipeList = [Recipes]()
    var filteredMyPublicRecipeList = [Recipes]()
    var filteredMyPrivateRecipeList = [Recipes]()
    
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    var selectedRecipe = Recipes()
    
    var userList = [User]()
    
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
    var deleteCheck: Bool = false
    
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
        
        getMyFavourites(completion: {
            result in
            if result {
                for i in 0..<self.recipesID.count {
                    self.filteredFavouritesRecipeList.removeAll()
                    self.favRecipeList.fetchRecipes(refName: "Recipes", queryKey: "", queryValue: self.recipesID[i] as AnyObject, recipeToSearch: "", ref: self.ref) {
                        (result: [Recipes]) in
                        self.filteredFavouritesRecipeList += Recipes.generateModelArray(result)
                        self.tableView.reloadData()
                    }
                }
            }
        })
        
        self.setupSearchController()
        self.tableView.reloadData()
    }
    
    func reloadData() {
        getMyRecipes()
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
    
    func getMyRecipes() {
        
        self.myPrivateRecipeList.removeAll()
        self.filteredMyPrivateRecipeList.removeAll()
        self.tableView.reloadData()
        myPrivateRecipeList.fetchRecipes(refName: "UserRecipes", queryKey: "", queryValue: uid! as AnyObject, recipeToSearch: "", ref: ref) {
            (result: [Recipes]) in
            if result.isEmpty {
                self.myPrivateRecipeList = []
            } else {
                self.myPrivateRecipeList = result
                self.filteredMyPrivateRecipeList = Recipes.generateModelArray(self.myPrivateRecipeList)
                self.tableView.reloadData()
            }
        }
        
        self.myPublicRecipeList.removeAll()
        self.filteredMyPublicRecipeList.removeAll()
        self.tableView.reloadData()
        myPublicRecipeList.fetchRecipes(refName: "Recipes", queryKey:  "AddedBy", queryValue: uid! as AnyObject, recipeToSearch: "", ref: ref) {
            (result: [Recipes]) in
            self.myPublicRecipeList = result
            self.filteredMyPublicRecipeList = Recipes.generateModelArray(self.myPublicRecipeList)
            self.tableView.reloadData()
        }
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
        
        filteredMyPublicRecipeList = myPublicRecipeList.filter { recipe in
            let matchingCourse = (selectedCourse == .All) || (recipe.course == selectedCourse)
            let matchingText = (recipe.name?.lowercased().contains(searchText.lowercased()))! || searchText.lowercased().characters.count == 0
            return matchingCourse && matchingText
        }
        
        filteredMyPrivateRecipeList = myPrivateRecipeList.filter{ recipe in
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
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnValue: String = ""
        if (section == 0) {
            returnValue = "My Private Recipes"
        } else if (section == 1) {
            returnValue = "My Public Recipes"
        } else if (section == 2) {
            returnValue = "My Favourites"
        }
        return returnValue
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var returnValue: Int = 0
        if (section == 0) {
            returnValue = self.filteredMyPrivateRecipeList.count
        } else if (section == 1) {
            returnValue = self.filteredMyPublicRecipeList.count
        } else if (section == 2) {
              returnValue = self.filteredFavouritesRecipeList.count
            
        }
        return returnValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RecipeTableViewCell
        
        if (indexPath.section == 0){
            
            recipe = filteredMyPrivateRecipeList[indexPath.row]
            
            cell.labelRecipeName?.text = recipe.name
            cell.labelCourse.text = recipe.course.map { $0.rawValue }
            
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

        } else if (indexPath.section == 1){
            
            recipe = filteredMyPublicRecipeList[indexPath.row]
            
            cell.labelRecipeName?.text = recipe.name
            cell.labelCourse.text = recipe.course.map { $0.rawValue }
            
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
            
        } else if (indexPath.section == 2){
            
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
        let controller = nav.topViewController as! RecipeDetailViewController
    
        let indexPath = (sender as! NSIndexPath)
        var selectedRow = Recipes()
        
        if indexPath.section == 0 {
            selectedRow = filteredMyPrivateRecipeList[indexPath.row]
        } else if indexPath.section == 1 {
            selectedRow = filteredMyPublicRecipeList[indexPath.row]
        } else if indexPath.section == 2 {
            selectedRow = filteredFavouritesRecipeList[indexPath.row]
        }
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
            
            if indexPath.section == 0 {
                
                self.selectedRecipe = self.filteredMyPrivateRecipeList[indexPath.row]
                let alert = UIAlertController(title: "❗️", message: "Are you sure you want to delete this recipe?", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                    
                self.ref.child("UserRecipes").child(self.uid).child(self.selectedRecipe.id!).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("Failed to Delete Recipes", error as Any)
                        self.showAlert(title: "Error", message: "Failed to delete Recipe")
                        return
                    }
                })
                    alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler:nil))
                    
                    self.present(alert, animated: true, completion: nil)
                
                }))
            } else if indexPath.section == 1 {
                
                self.selectedRecipe = self.filteredMyPublicRecipeList[indexPath.row]
                let alert = UIAlertController(title: "❗️", message: "Are you sure you want to delete this recipe?", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                    
                    self.ref.child("Recipes").child(self.selectedRecipe.id!).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("Failed to Delete Recipes", error as Any)
                        self.showAlert(title: "Error", message: "Failed to delete Recipe")
                        return
                    }
                })
                self.filteredMyPublicRecipeList.remove(at: indexPath.row)
                self.tableView.reloadData()
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler:nil))
                
                self.present(alert, animated: true, completion: nil)
                
            } else if indexPath.section == 2 {
                
                let alert = UIAlertController(title: "❗️", message: "Are you sure you want to remove this recipe from favourites?", preferredStyle: UIAlertControllerStyle.actionSheet)
                
                alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
                    let removeFavouriteRef = self.ref.child("Users").child(self.uid).child("Favourites")
                    query = removeFavouriteRef.queryOrdered(byChild: "RecipeID").queryEqual(toValue: self.selectedRecipe.id)
                    query.observe(.value, with: { (snapshot) in
                        if snapshot.exists() {
                            print(snapshot)
                        }
                    })
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    

    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
    }
}
