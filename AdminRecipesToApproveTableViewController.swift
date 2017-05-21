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
    
    @IBOutlet weak var recipesToApproveTableView: UITableView!
    
    
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
        
        // Add's an Observer to the Notificaition center to observe post from other classes with the relevant name.
        NotificationCenter.default.addObserver(self, selector: #selector(getRecipes), name: NSNotification.Name(rawValue: "getRecipes"), object: nil)

        getRecipes()
        self.setupSearchController()
        self.recipesToApproveTableView.reloadData()
    }
    
    func getRecipes(){
        recipeList.removeAll()
        
        // Retrieve all recipes that are approved by admin. This recipeList uses the recipe extension.
        recipeList.fetchRecipes(refName: "Recipes", queryKey: "Approved", queryValue: false as AnyObject, recipeToSearch: "", ref: ref) {
            (result: [Recipes]) in
            if result.isEmpty {
                self.recipeList = []
                self.recipesToApproveTableView.reloadData()
            } else {
                self.recipeList = result
                self.recipesToApproveTableView.reloadData()
            }
        }
        print("No Recipes")
    }
    
    func fetchUserWhoAddedRecipe(completion: @escaping (Bool) -> ()) {
        // Fetches each user associated with the recipe. The user ID is stored within the Recipe as 'addedBy'.
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
    
    // Create the search controller to allow users to search and use the built in segment control.
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
    
    // MARK: - Table view data source
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return recipeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       performSegue(withIdentifier: "ReicpeToAproveDetailsSegue", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 72
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nav = segue.destination as! UINavigationController
        
        if segue.identifier == "ReicpeToAproveDetailsSegue" {
            let controller = nav.topViewController as! AdminRecipesToApproveViewController
            
            let indexPath = (sender as! NSIndexPath)
            let selectedRow = recipeList[indexPath.row].id
            controller.recipeId = selectedRow!
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
