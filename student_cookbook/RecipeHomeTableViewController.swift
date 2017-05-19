//
//  RecipeHomeTableViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 12/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import FirebaseAuth

class RecipeHomeTableViewController: UITableViewController {
    
    var recipeToSearch: String = ""
    var recipePressed: Bool = false
    
    var recipesToSearchList = ["All Recipes", "Breakfast", "Lunch", "Dinner", "Dessert", "Quick", "Easy", "Healthy", "On a Budget", "Treat Yourself"]
    
    var pictures: [UIImage] = [
        UIImage(named: "Background-3.png")!,
        UIImage(named: "BreakfastImage.png")!,
        UIImage(named: "LunchImage.png")!,
        UIImage(named: "DinnerImage.png")!,
        UIImage(named: "DessertImage.png")!,
        UIImage(named: "QuickImage.png")!,
        UIImage(named: "EasyImage.png")!,
        UIImage(named: "HealthyImage.png")!,
        UIImage(named: "OnABudgetImage.png")!,
        UIImage(named: "TreatYourselfImage.png")!
    ]
    
    
    @IBAction func buttonAdd(_ sender: Any) {
        performSegue(withIdentifier: "AddRecipeSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipesToSearchList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipesHomeCell", for: indexPath) as! RecipeHomeTableViewCell
        
        cell.imageViewRecipeDesc?.image = self.pictures[indexPath.row]
        cell.imageViewRecipeDesc.contentMode = .scaleAspectFill
        cell.labelRecipeDesc.text = "\(self.recipesToSearchList[indexPath.row])"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if recipesToSearchList[indexPath.row] == "All Recipes" {
            recipeToSearch = ""
        } else {
            recipeToSearch =  recipesToSearchList[indexPath.row]
        }
        
        recipePressed = true
        performSegue(withIdentifier: "ShowSelectedRecipesSegue", sender: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ShowSelectedRecipesSegue" {
            if recipePressed == true {
                return true
            } else {
                return false
            }
        } else if identifier == "AddRecipeSegue" {
            return true
        } else {
            return false
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        
        if segue.identifier == "ShowSelectedRecipesSegue" {
            let controller = nav.topViewController as! RecipeTableViewController
            controller.recipeToSearch = self.recipeToSearch
            recipePressed = false
        }
    }
}

class RecipeHomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewRecipeDesc: UIImageView!
    @IBOutlet weak var labelRecipeDesc: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "RecipesHomeCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
