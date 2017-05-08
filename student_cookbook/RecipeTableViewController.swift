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

class RecipeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    var currentStoryboard: UIStoryboard!
    var currentStoryboardName: String!
    
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    
    var recipe: Recipes?
    var recipeList = [Recipes]()
    var userRecipeList = [Recipes]()
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    var userList = [User]()
    
    var filteredUserRecipeList = [Recipes]()
    var filteredRecipeList = [Recipes]()
    var recipeIDArray = [String]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    var mainStoryBoard: Bool = false
    
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
        
        self.recipesTableView.register(AdminRecipeTableViewCell.self, forCellReuseIdentifier: "RecipesCell")
        
        ref = FIRDatabase.database().reference()
        
        uid = FIRAuth.auth()?.currentUser?.uid
        
        if uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        getRecipes()
        
        self.setupSearchController()
        self.recipesTableView.reloadData()
    }
    
    func registerNib(){
        
        if self.currentStoryboardName == "Main" {
            let cellNib = UINib(nibName: "RecipeTableViewCell", bundle: nil)
            self.recipesTableView.register(cellNib, forCellReuseIdentifier: "RecipeCell")
            mainStoryBoard = true
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
        
        if self.currentStoryboardName == "Ipad" {
            userRecipeList.fetchRecipes(refName: "UserRecipes", queryKey: "",queryValue: false as AnyObject, ref: ref) {
                (result: [Recipes]) in
                if result.isEmpty {
                    self.userRecipeList = []
                    self.filteredUserRecipeList = self.recipeList
                } else {
                    self.userRecipeList = result
                    self.filteredUserRecipeList = Recipes.generateModelArray(self.recipeList)
                    self.recipesTableView.reloadData()
                    
                }
            }
        }
        self.recipesTableView.reloadData()
    }
    
    func addRating(){
        
    }
    
    func fillData(){
        
        labelRecipeName.text = self.recipe?.name
        labelServingSize.text = "Serves: \(self.recipe!.servingSize!)"
        labelPrepTime.text = " \(self.recipe!.prepTimeHour!) hrs \(self.recipe!.prepTimeMinute!) mins"
        labelCookTime.text = "\(self.recipe!.cookTimeHour!) hrs \(self.recipe!.cookTimeMinute!) mins"
        labelType.text = self.recipe!.type
        labelCourse.text = (self.recipe?.course).map { $0.rawValue }
        ingredientsList = self.recipe!.ingredients
        stepsList = self.recipe!.steps
        
        let imageURL = self.recipe?.imageURL
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
        userList.fetchUsers(refName: "Users", queryKey: self.recipe!.addedBy!, queryValue: "" as AnyObject, ref: ref) {
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
        
        if mainStoryBoard == true {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            present(vc!, animated: true, completion: nil)
        } else {
            let vc = UIStoryboard(name: "Ipad", bundle: nil).instantiateInitialViewController()
            present(vc!, animated: true, completion: nil)
        }
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        recipesTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All","Breakfast","Lunch","Dinner", "Dessert", "Snack"]
        searchController.searchBar.delegate = self as UISearchBarDelegate
    }
    
    func filterSearchController(searchBar: UISearchBar){
        guard let scopeString = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] else { return }
        let selectedCourse = Recipes.Course(rawValue: scopeString) ?? .All
        let searchText = searchBar.text ?? ""
        
        filteredRecipeList = recipeList.filter { recipe in
            let matchingCourse = (selectedCourse == .All) || (recipe.course == selectedCourse)
            let matchingText = (recipe.name?.lowercased().contains(searchText.lowercased()))! || searchText.lowercased().characters.count == 0
            return matchingCourse && matchingText
        }
        
        filteredUserRecipeList = userRecipeList.filter { recipe in
            let matchingCourse = (selectedCourse == .All) || (recipe.course == selectedCourse)
            let matchingText = (recipe.name?.lowercased().contains(searchText.lowercased()))! || searchText.lowercased().characters.count == 0
            return matchingCourse && matchingText
        }
        
        recipesTableView.reloadData()
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
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnValue: String = ""
        
        if currentStoryboardName == "Ipad" {
            if tableView == self.ingredientsAndStepsTableView {
                if section == 0 {
                    returnValue = "Ingredients"
                } else if section == 1 {
                    returnValue = "Steps"
                }
            }
        }
        return returnValue
    }
    
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
            returnValue = searchController.isActive ? filteredRecipeList.count : recipeList.count
            
        }
        if self.currentStoryboardName == "Ipad" {
            if (tableView == self.ingredientsAndStepsTableView){
                if (section == 0){
                    returnValue = self.ingredientsList.count
                } else if (section == 1){
                    returnValue = self.stepsList.count
                }
            }
        }
        return returnValue
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if tableView == self.recipesTableView {
            
            let recipe = searchController.isActive ? filteredRecipeList[indexPath.row] : recipeList[indexPath.row]
            
            if currentStoryboardName == "Main" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeTableViewCell
                
                cell.labelRecipeName?.text = recipe.name
                
                self.recipe = recipe
                
                fetchUserWhoAddedRecipe(completion: {
                    result in
                    if result {
                        cell.labelRecipeAddedBy?.text = "Added by: \(self.userList[0].firstName!) \(self.userList[0].lastName!)"
                    }
                })
                
                if recipe.imageURL != nil {
                    if let recipeImageURL = recipe.imageURL {
                        cell.recipeImageView?.loadImageWithCacheWithUrlString(recipeImageURL)
                    }
                }
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecipesCell", for: indexPath) as! AdminRecipeTableViewCell
                
                cell.textLabel?.text = recipe.name
                
                self.recipe = recipe
                
                fetchUserWhoAddedRecipe(completion: {
                    result in
                    if result {
                        cell.detailTextLabel?.text = "Added by: \(self.userList[0].firstName!) \(self.userList[0].lastName!)"
                    }
                })
                
                if recipe.imageURL != nil {
                    if let recipeImageURL = recipe.imageURL {
                        cell.recipeImageView.loadImageWithCacheWithUrlString(recipeImageURL)
                    }
                }
                return cell
            }
            
        }
        
        if tableView == self.ingredientsAndStepsTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsAndStepsCell", for: indexPath)
            
            
            if (indexPath.section == 0) {
                cell.textLabel?.text = ingredientsList[indexPath.row].name
                cell.detailTextLabel?.text = "\(ingredientsList[indexPath.row].quantity!)  \( ingredientsList[indexPath.row].measurement!)"
                
                
            } else {
                
                cell.textLabel?.text = (stepsList[indexPath.row].stepNo).map{ String($0)}
                cell.detailTextLabel?.numberOfLines = 0
                cell.detailTextLabel?.lineBreakMode = .byWordWrapping
                cell.detailTextLabel?.text = stepsList[indexPath.row].stepDesc
            }
             return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsAndStepsCell", for: indexPath)
            cell.textLabel?.text = ""
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.currentStoryboardName == "Main") {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "RecipeDetailSegue", sender: indexPath)
        } else if (self.currentStoryboardName == "Ipad"){
            
            if (tableView == self.recipesTableView){
                self.recipe = self.filteredRecipeList[indexPath.row]
                recipeSelected = true
                self.ingredientsList = (recipe?.ingredients)!
                self.stepsList = (recipe?.steps)!
                fillData()
                self.ingredientsAndStepsTableView.reloadData()
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

class AdminRecipeTableViewCell: UITableViewCell {
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setCircleSize()
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "RecipesCell")
        
        addSubview(recipeImageView)
        
        recipeImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        recipeImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        recipeImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        recipeImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
