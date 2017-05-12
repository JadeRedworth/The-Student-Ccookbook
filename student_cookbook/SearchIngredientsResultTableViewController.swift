//
//  SearchIngredientsResultTableViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 27/04/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SearchIngredientsResultTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    
    var recipeList = [Recipes]()
    var ingredientsList = [Ingredients]()
    var stepsList = [Steps]()
    
    var recipesID = [String]()

    var ingredientsToSearch = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        getRecipes() {
            result in
            if result {
                for i in 0..<self.recipesID.count {
                    self.recipeList.fetchRecipes(refName: "Recipes", queryKey: "", queryValue: self.recipesID[i] as AnyObject, recipeToSearch: "", ref: self.ref) {
                        (result: [Recipes]) in
                        print(result)
                            self.recipeList += result
                        
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func getRecipes(completion: @escaping (_ result: Bool) -> Void) {
        let ingredientsRef = self.ref.child("Recipes")
        ingredientsRef.observe(.childAdded, with: { (snapshot) in
            let ingredientsEnumerator = snapshot.childSnapshot(forPath: "Ingredients").children
            print(ingredientsEnumerator)
            while let ingItem = ingredientsEnumerator.nextObject() as? FIRDataSnapshot {
                let t: String = (ingItem.childSnapshot(forPath: "Name").value as? String)!
                if t == self.ingredientsToSearch[0] {
                    self.recipesID.append(snapshot.key)
                }
            }
            completion(true)
        })
    }
    
    @IBAction func buttonBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchIngredientsCell", for: indexPath)

        let recipe = recipeList[indexPath.row]
        cell.textLabel?.text = recipe.name
        cell.detailTextLabel?.text = recipe.course?.rawValue

        return cell
    }
}
