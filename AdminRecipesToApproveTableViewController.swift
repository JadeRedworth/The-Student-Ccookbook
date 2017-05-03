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

class AdminRecipesToApproveTableViewController: UITableViewController {
    
    let cellId = "cellId"
    
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    
    var recipeList = [Recipes]()
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    
    //var selectedRecipeList = [Recipes]()
    //var filteredRecipeList = [Recipes]()
    //var recipeIDArray = [String]()
    
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
        
        tableView.register(AdminTableViewCell.self, forCellReuseIdentifier: cellId)
        
        getRecipes()
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear")
        getRecipes()
        self.tableView.reloadData()
    }
    
    func getRecipes(){
        recipeList.fetchRecipes(refName: "Recipes", queryKey: "Approved", queryValue: false as AnyObject, ref: ref) {
            (result: [Recipes]) in
            if result.isEmpty {
                self.recipeList = []
                self.tableView.reloadData()
            } else {
                self.recipeList = result
                self.tableView.reloadData()
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
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return recipeList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AdminTableViewCell
        
        let recipe = recipeList[indexPath.row]
        
        cell.textLabel?.text = recipe.name
        cell.detailTextLabel?.text = recipe.addedBy
        
        if recipeList[indexPath.row].imageURL != nil {
            
            if let recipeImageURL = recipeList[indexPath.row].imageURL {
                cell.recipeImageView.loadImageWithCacheWithUrlString(recipeImageURL)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ApprovedDetailSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let nav = segue.destination as! UINavigationController
        
        if segue.identifier == "ApprovedDetailSegue" {
            let controller = nav.topViewController as! AdminApproveDetailsViewController
            
            let indexPath = (sender as! NSIndexPath)
            let selectedRow = recipeList[indexPath.row]
            controller.recipe = selectedRow
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
