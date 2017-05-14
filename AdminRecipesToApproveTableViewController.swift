//
//  AdminRecipesToApproveTableViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 25/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class AdminRecipesToApproveTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    let cellId = "cellId"
    
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    
    var recipeSelected: Bool = false
    
    // Model
    var recipe: Recipes!
    var imageURL: String?
    var returnValue: Int?
    
    var recipeList = [Recipes]()
    var filteredRecipeList = [Recipes]()
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    var userList = [User]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    //var selectedRecipeList = [Recipes]()
    //var filteredRecipeList = [Recipes]()
    //var recipeIDArray = [String]()
    
    @IBOutlet weak var recipesToApproveTableView: UITableView!
    @IBOutlet weak var ingredientsAndStepsTableView: UITableView!
    
    // Image outlets
    @IBOutlet weak var imageViewRecipe: UIImageView!
    
    // Label outlets
    @IBOutlet weak var labelRecipeName: UILabel!
    @IBOutlet weak var labelServingSize: UILabel!
    @IBOutlet weak var labelPrepTime: UILabel!
    @IBOutlet weak var labelCookTime: UILabel!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelCourse: UILabel!
    @IBOutlet weak var labelAddedBy: UILabel!
    @IBOutlet weak var labelDateAdded: UILabel!
    
    @IBOutlet weak var buttonApprove: UIButton!
    
    @IBAction func buttonLogout(_ sender: Any) {
        handleLogout()
    }
    
    var recipeID: String!
    //var valueToPass:String!
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dismissKeyboardWhenTappedAround()
        
        ref = FIRDatabase.database().reference()
        uid = FIRAuth.auth()?.currentUser?.uid
        
        if uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        self.recipesToApproveTableView.register(AdminRecipesToApproveTableViewCell.self, forCellReuseIdentifier: cellId)
        
        getRecipes()
        
        self.setupSearchController()
        self.recipesToApproveTableView.reloadData()
    }
    
    
    func fillData(){
        if self.recipe != nil {
            if recipeSelected != true {
                self.recipe = self.recipeList[0]
            }
            
            labelRecipeName.text = self.recipe?.name
            labelServingSize.text = "Serves: \(String(describing: self.recipe?.servingSize))"
            labelPrepTime.text = " \(String(describing: self.recipe!.prepTimeHour)) hrs \(self.recipe!.prepTimeMinute!) mins"
            labelCookTime.text = "\(String(describing: self.recipe!.cookTimeHour)) hrs \(String(describing: self.recipe!.cookTimeMinute)) mins"
            labelType.text = self.recipe?.type
            labelCourse.text = (self.recipe?.course).map { $0.rawValue }
            labelAddedBy.text = self.recipe!.addedBy
            
            imageURL = self.recipe?.imageURL
            imageViewRecipe.loadImageWithCacheWithUrlString(imageURL!)
        }
        
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
    
    func getRecipes(){
        recipeList.fetchRecipes(refName: "Recipes", queryKey: "Approved", queryValue: false as AnyObject, recipeToSearch: "", ref: ref) {
            (result: [Recipes]) in
            if result.isEmpty {
                self.recipeList = []
                self.recipesToApproveTableView.reloadData()
            } else {
                self.recipeList = result
                self.recipesToApproveTableView.reloadData()
            }
            self.fillData()
            self.recipesToApproveTableView.reloadData()
        }
        print("No Recipes")
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        recipesToApproveTableView.tableHeaderView = searchController.searchBar
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
        
        recipesToApproveTableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchBar: searchController.searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterSearchController(searchBar: searchBar)
    }
    
    func handleLogout() {
        try! FIRAuth.auth()!.signOut()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonApprove(_ sender: Any) {
        
        let recipeRef = self.ref.child("Recipes").child((recipe?.id)!).child("Approved")
        recipeRef.setValue(true)
        getRecipes()
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnValue: String = ""
        
        if tableView == self.ingredientsAndStepsTableView {
            if section == 0 {
                returnValue = "Ingredients"
            } else if section == 1 {
                returnValue = "Steps"
            }
        }
        return returnValue
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var returnValue: Int = 0
        
        if (tableView == self.recipesToApproveTableView){
            returnValue = 1
        } else if (tableView == self.ingredientsAndStepsTableView){
            returnValue = 2
        }
        
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var returnValue: Int = 0
        
        if tableView == self.recipesToApproveTableView {
            returnValue = self.recipeList.count
        } else if tableView == self.ingredientsAndStepsTableView {
            if section == 0 {
                returnValue = self.ingredientsList.count
            } else if section == 1 {
                returnValue = self.stepsList.count
            }
        }
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.recipesToApproveTableView {
            
            let recipe = self.recipeList[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AdminRecipesToApproveTableViewCell
            
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
        
        if tableView == self.recipesToApproveTableView {
            recipeSelected = true
            self.recipe = self.recipeList[indexPath.row]
            self.ingredientsList = recipe.ingredients
            self.stepsList = recipe.steps
            fillData()
            self.ingredientsAndStepsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.recipesToApproveTableView {
            return 72
        } else {
            return 40
        }
    }
}

class AdminRecipesToApproveTableViewCell: UITableViewCell {
    
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
        super.init(style: .subtitle, reuseIdentifier: "RecipesToApproveCell")
        
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
