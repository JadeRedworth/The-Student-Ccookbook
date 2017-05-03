//
//  AdminApproveDetailsViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 26/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AdminApproveDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    
    // Model
    var recipe: Recipes!
    var imageURL: String?
    var returnValue: Int?
    
    // View outlets
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var ingredientsView: UIView!
    @IBOutlet weak var stepsView: UIView!
    
    
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
    
    // Segment Control
    @IBOutlet weak var SegmentedControl: SegmentedControl!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var stepsTableView: UITableView!
    
    @IBOutlet weak var textFieldComment: UITextField!
    @IBOutlet weak var buttonApprove: UIButton!
    
    // Actions
    @IBAction func buttonBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonApprove(_ sender: Any) {
    
        let recipeRef = self.ref.child("Recipes").child((recipe?.id)!).child("Approved")
        recipeRef.setValue(true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoView.alpha = 1
        ingredientsView.alpha = 0
        stepsView.alpha = 0
        
        ref = FIRDatabase.database().reference()
        fillData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func segmentedControlActionChanged(sender: SegmentedControl) {
        
        switch sender.selectedIndex {
        case 0:
            infoView.alpha = 1
            ingredientsView.alpha = 0
            stepsView.alpha = 0
        case 1:
            infoView.alpha = 0
            ingredientsView.alpha = 1
            stepsView.alpha = 0
        case 2:
            infoView.alpha = 0
            ingredientsView.alpha = 0
            stepsView.alpha = 1
        default:
            break;
        }
    }
    
    // MARK: Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        returnValue = 0
        
        if tableView == self.ingredientsTableView {
            returnValue = recipe?.ingredients.count
        } else if tableView == self.stepsTableView {
            returnValue = recipe?.steps.count
        }
        return returnValue!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = nil
        
        if tableView == self.ingredientsTableView {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "IngredientsCell", for: indexPath)
            cell?.textLabel?.text = self.recipe?.ingredients[indexPath.row].name
            cell?.detailTextLabel?.text = ("\(String(describing: self.recipe?.ingredients[indexPath.row].quantity!)) " + (self.recipe?.ingredients[indexPath.row].measurement!)!)
        
        } else if tableView == self.stepsTableView {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "StepsCell", for: indexPath)
            cell?.textLabel?.text = "\(String(describing: self.recipe?.steps[indexPath.row].stepNo))"
            cell?.detailTextLabel?.text = self.recipe?.steps[indexPath.row].stepDesc
        }
        return cell!
    }
}
