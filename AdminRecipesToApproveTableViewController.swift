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

class AdminRecipesToApproveTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellId = "cellId"
    
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    
    var recipeSelected: Bool = false
    
    // Model
    var recipe: Recipes!
    var imageURL: String?
    var returnValue: Int?
    
    var recipeList = [Recipes]()
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    
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
        
        self.recipesToApproveTableView.register(AdminTableViewCell.self, forCellReuseIdentifier: cellId)
        
        getRecipes()
        
        if recipeSelected == true {
            fillData()
        }
        
        self.recipesToApproveTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear")
        getRecipes()
        self.recipesToApproveTableView.reloadData()
    }
    
    func fillData(){
        
        labelRecipeName.text = self.recipe?.name
        labelServingSize.text = "Serves: \(String(describing: self.recipe?.servingSize))"
        labelPrepTime.text = " \(String(describing: self.recipe!.prepTimeHour)) hrs \(self.recipe!.prepTimeMinute!) mins"
        labelCookTime.text = "\(String(describing: self.recipe!.cookTimeHour)) hrs \(String(describing: self.recipe!.cookTimeMinute)) mins"
        labelType.text = self.recipe?.type
        labelCourse.text = self.recipe?.course
        labelAddedBy.text = self.recipe!.addedBy
        
        imageURL = self.recipe?.imageURL
        imageViewRecipe.loadImageWithCacheWithUrlString(imageURL!)
        
    }
    
    func getRecipes(){
        recipeList.fetchRecipes(refName: "Recipes", queryKey: "Approved", queryValue: false as AnyObject, ref: ref) {
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
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var returnValue: Int = 0
        
        if tableView == self.recipesToApproveTableView {
            returnValue = recipeList.count
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
        
        let recipe = recipeList[indexPath.row]
        
        if tableView == self.recipesToApproveTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AdminTableViewCell
            
            cell.textLabel?.text = recipe.name
            cell.detailTextLabel?.text = recipe.addedBy
            
            if recipe.imageURL != nil {
                
                if let recipeImageURL = recipe.imageURL {
                    cell.recipeImageView.loadImageWithCacheWithUrlString(recipeImageURL)
                }
            }
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsAndStepsCell", for: indexPath)
            
            if indexPath.section == 0 {
                cell.textLabel?.text = recipe.ingredients[indexPath.row].name
                cell.detailTextLabel?.text = "\(recipe.ingredients[indexPath.row].quantity!) \(recipe.ingredients[indexPath.row].measurement!)"
                
                return cell

            } else {
                
                cell.textLabel?.text = "\(recipe.steps[indexPath.row].stepNo!)"
                cell.detailTextLabel?.text = recipe.steps[indexPath.row].stepDesc
                
                return cell
            }
        }
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.recipesToApproveTableView {
            recipeSelected = true
        }
    }
}

class AdminTableViewCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setRectangleSize()
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "AdminApproveCell")
        
        addSubview(recipeImageView)
        
        recipeImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        recipeImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        recipeImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        recipeImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
