//
//  RecipeViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 06/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

enum recipesSelectedScope:Int {
    case all = 0
    case breakfast = 1
    case lunch = 2
    case dinner = 3
    case dessert = 4
    case snack = 5
}

class RecipeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var currentStoryboard: UIStoryboard!
    var currentStoryboardName: String!
    
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    
    var recipe: Recipes?
    var recipeList = [Recipes]()
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    var userList = [User]()
    
    var selectedRecipeList = [Recipes]()
    var filteredRecipeList = [Recipes]()
    var recipeIDArray = [String]()
    
    var recipeSelected: Bool = false
    
    @IBAction func buttonLogout(_ sender: Any) {
        handleLogout()
    }
    
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
    
    
    @IBOutlet weak var recipesTableView: UITableView!
    @IBOutlet weak var ingredientsAndStepsTableView: UITableView!
    
    var recipeID: String!
    var valueToPass:String!
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentStoryboard = self.storyboard
        self.currentStoryboardName = currentStoryboard.value(forKey: "name") as! String
        
        self.dismissKeyboardWhenTappedAround()
        
        registerNib()
        
        ref = FIRDatabase.database().reference()
        
        uid = FIRAuth.auth()?.currentUser?.uid
        
        if uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        getRecipes()
        
        self.searchBarSetup()
        self.recipesTableView.reloadData()
    }
    
    func registerNib(){
        
        if self.currentStoryboardName == "Main" {
            let cellNib = UINib(nibName: "RecipeTableViewCell", bundle: nil)
            self.recipesTableView.register(cellNib, forCellReuseIdentifier: "RecipeCell")
        } else if self.currentStoryboardName == "Ipad" {
            let cellNib = UINib(nibName: "AdminRecipeTableViewCell", bundle: nil)
            self.recipesTableView.register(cellNib, forCellReuseIdentifier: "RecipeCell")
        }
    }
    
    func reloadData() {
        getRecipes()
        recipesTableView.reloadData()
    }
    
    
    func getRecipes(){
        recipeList.fetchRecipes(refName: "Recipes", queryKey: "Approved",queryValue: true as AnyObject, ref: ref) {
            (result: [Recipes]) in
            if result.isEmpty {
                self.recipeList = []
                self.filteredRecipeList = self.recipeList
                self.recipesTableView.reloadData()
            } else {
                self.recipeList = result
                self.filteredRecipeList = Recipes.generateModelArray(self.recipeList)
                self.recipesTableView.reloadData()
            }
        }
        recipesTableView.reloadData()
    }
    
    func fillData(){
        
        labelRecipeName.text = recipe?.name
        labelServingSize.text = "Serves: \(recipe!.servingSize!)"
        labelPrepTime.text = " \(recipe!.prepTimeHour!) hrs \(recipe!.prepTimeMinute!) mins"
        labelCookTime.text = "\(recipe!.cookTimeHour!) hrs \(recipe!.cookTimeMinute!) mins"
        labelType.text = recipe?.type
        labelCourse.text = recipe?.course
        ingredientsList = recipe!.ingredients
        stepsList = recipe!.steps
        
        let imageURL = recipe?.imageURL
        imageViewRecipe.loadImageWithCacheWithUrlString(imageURL!)
        
        fetchUserWhoAddedRecipe(completion: {
            result in
            if result {
                self.labelAddedBy.text = "\(self.userList[0].firstName!) \(self.userList[0].lastName!)"
                if let userProfileURL = self.userList[0].profilePicURL {
                    self.imageViewUser.loadImageWithCacheWithUrlString(userProfileURL)
                    self.imageViewUser.makeImageCircle()
                    self.imageViewUser.contentMode = .scaleAspectFill
                }
            }
        })
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

    
    func handleLogout() {
        try! FIRAuth.auth()!.signOut()
        
        if self.currentStoryboardName == "Main" {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            present(vc!, animated: true, completion: nil)
        } else if self.currentStoryboardName == "Ipad" {
            let vc = UIStoryboard(name: "Ipad", bundle: nil).instantiateInitialViewController()
            present(vc!, animated: true, completion: nil)
        }
    }
    
    func searchBarSetup() {
        let searchBar = UISearchBar(frame: CGRect(x:0,y:0,width:(UIScreen.main.bounds.width),height:70))
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["All", "Breakfast","Lunch","Dinner", "Dessert", "Snack"]
        searchBar.selectedScopeButtonIndex = 0
        searchBar.delegate = self
        recipesTableView.tableHeaderView = searchBar
    }
    
    // MARK: - search bar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredRecipeList = recipeList
            recipesTableView.reloadData()
        } else {
            filterTableView(searchBar.selectedScopeButtonIndex, text: searchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 0 {
            filteredRecipeList = recipeList
            recipesTableView.reloadData()
            
        } else if selectedScope == 1 {
            filteredRecipeList = recipeList.filter({ (breakfast) -> Bool in
                return (breakfast.course?.contains("Breakfast"))!
            })
            recipesTableView.reloadData()
            selectedRecipeList = filteredRecipeList
            
        } else if selectedScope == 2 {
            filteredRecipeList = recipeList.filter({ (lunch) -> Bool in
                return (lunch.course?.contains("Lunch"))!
            })
            recipesTableView.reloadData()
            selectedRecipeList = filteredRecipeList
            
        } else if selectedScope == 3 {
            filteredRecipeList = recipeList.filter({ (dinner) -> Bool in
                return (dinner.course?.contains("Dinner"))!
            })
            recipesTableView.reloadData()
            selectedRecipeList = filteredRecipeList
            
        } else if selectedScope == 4 {
            filteredRecipeList = recipeList.filter({ (dessert) -> Bool in
                return (dessert.course?.contains("Dessert"))!
            })
            recipesTableView.reloadData()
            selectedRecipeList = filteredRecipeList
            
        } else if selectedScope == 5 {
            filteredRecipeList = recipeList.filter({ (snack) -> Bool in
                return (snack.course?.contains("Snack"))!
            })
            recipesTableView.reloadData()
            selectedRecipeList = filteredRecipeList
        }
    }
    
    func filterTableView(_ ind: Int, text: String) {
        switch ind {
        case recipesSelectedScope.all.rawValue:
            filteredRecipeList = recipeList.filter({ (recipes) -> Bool in
                return (recipes.name?.lowercased().contains(text.lowercased()))! ||
                    (recipes.type?.lowercased().contains(text.lowercased()))!
            })
            recipesTableView.reloadData()
            break
            
        case recipesSelectedScope.breakfast.rawValue:
            filteredRecipeList = selectedRecipeList.filter({ (breakfast) -> Bool in
                return (breakfast.name?.lowercased().contains(text.lowercased()))! ||
                    (breakfast.type?.lowercased().contains(text.lowercased()))!
            })
            recipesTableView.reloadData()
            break
            
        case recipesSelectedScope.lunch.rawValue:
            filteredRecipeList = selectedRecipeList.filter({ (lunch) -> Bool in
                return (lunch.name?.lowercased().contains(text.lowercased()))! ||
                    (lunch.type?.lowercased().contains(text.lowercased()))!
            })
            recipesTableView.reloadData()
            break
            
        case recipesSelectedScope.dinner.rawValue:
            filteredRecipeList = selectedRecipeList.filter({ (dinner) -> Bool in
                return (dinner.name?.lowercased().contains(text.lowercased()))! ||
                    (dinner.type?.lowercased().contains(text.lowercased()))!
            })
            recipesTableView.reloadData()
            break
            
        case recipesSelectedScope.dessert.rawValue:
            filteredRecipeList = selectedRecipeList.filter({ (dessert) -> Bool in
                return (dessert.name?.lowercased().contains(text.lowercased()))! ||
                    (dessert.type?.lowercased().contains(text.lowercased()))!
            })
            recipesTableView.reloadData()
            break
            
        case recipesSelectedScope.snack.rawValue:
            filteredRecipeList = selectedRecipeList.filter({ (snack) -> Bool in
                return (snack.name?.lowercased().contains(text.lowercased()))! ||
                    (snack.type?.lowercased().contains(text.lowercased()))!
            })
            recipesTableView
                .reloadData()
            break
            
        default:
            print("No Recipes")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var returnValue: Int = 0
        
        if (tableView == self.recipesTableView){
            returnValue = 1
            
        } else if (tableView == self.ingredientsAndStepsTableView){
            returnValue = 2
        }
        
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        var returnValue: Bool = false
        
        if (tableView == self.recipesTableView){
            returnValue = true
        } else if (tableView == self.ingredientsAndStepsTableView){
            returnValue = false
        }
        
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let favorites = UITableViewRowAction(style: .normal, title: "Add To Favourites") { action, index in
            let userRef = self.ref.child("Users").child(self.uid).child("Favourites").childByAutoId()
            let favValue = ["RecipeID": self.filteredRecipeList[indexPath.row].id]
            userRef.setValue(favValue)
            self.showAlert(title: "Success", message: "Recipe has been added to Favourites")
            
        }
        favorites.backgroundColor = UIColor.blue
        
        return [favorites]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var returnValue: Int = 0
        
        if (tableView == self.recipesTableView){
            returnValue = self.filteredRecipeList.count
        } else if (tableView == self.ingredientsAndStepsTableView){
            if (section == 0){
                returnValue = self.ingredientsList.count
            } else if (section == 1){
                returnValue = self.stepsList.count
            }
        }
        
        return returnValue
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let recipe = filteredRecipeList[indexPath.row]
        
        if (self.currentStoryboardName == "Main") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeTableViewCell
            
            cell.labelRecipeName.text = recipe.name
            cell.labelRecipeAddedBy.text = "@: \(recipe.addedBy!)"
            
            if recipe.imageURL != nil {
                if let recipeImageURL = recipe.imageURL {
                    cell.recipeImageView.loadImageWithCacheWithUrlString(recipeImageURL)
                }
            }
            
            return cell
            
        } else {
            
            if (tableView == self.recipesTableView){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! AdminRecipeTableViewCell
                
                cell.labelRecipeName.text = recipe.name
                cell.labelAddedBy.text = "@: \(recipe.addedBy!)"
                
                if recipe.imageURL != nil {
                    if let recipeImageURL = recipe.imageURL {
                        cell.imageViewRecipe.loadImageWithCacheWithUrlString(recipeImageURL)
                    }
                }
                
                return cell
            } else {
                
                 let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsAndStepsDetailCell", for: indexPath)
                
                if recipeSelected == true {
                    
                       let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsAndStepsDetailCell", for: indexPath)
                    
                    
                    
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
                } else {
                    if (indexPath.section == 0) {
                        cell.textLabel?.text = ""
                        cell.detailTextLabel?.text = ""
                
                    } else if (indexPath.section == 1){
                
                        cell.textLabel?.text = ""
                        cell.detailTextLabel?.numberOfLines = 0
                        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
                        cell.detailTextLabel?.text = stepsList[indexPath.row].stepDesc
                    }
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.currentStoryboardName == "Main") {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "RecipeDetailSegue", sender: indexPath)
        } else if (self.currentStoryboardName == "Ipad"){
            
            self.recipe = self.filteredRecipeList[indexPath.row]
            
            if (tableView == self.recipesTableView){
                
                recipeSelected = true
                fillData()
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        
        if segue.identifier == "RecipeDetailSegue" {
            let controller = nav.topViewController as! RecipeDetailViewController
            
            let indexPath = (sender as! NSIndexPath)
            let selectedRow = filteredRecipeList[indexPath.row]
            controller.recipe = selectedRow
        }
    }
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
    }
}
