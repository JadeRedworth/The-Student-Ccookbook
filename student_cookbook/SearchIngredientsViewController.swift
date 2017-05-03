//
//  SearchIngredientsViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 27/04/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit

class SearchIngredientsViewController: UIViewController {

    @IBOutlet weak var textFieldIngredient1: UITextField!
    @IBOutlet weak var textFieldIngredient2: UITextField!
    @IBOutlet weak var textFieldIngredient3: UITextField!
    
    @IBAction func buttonSearchIngredients(_ sender: Any) {
        if textFieldIngredient1.text != "" {
            ingredientsToSearch.append(textFieldIngredient1.text!)
        } else if textFieldIngredient2.text != "" {
            ingredientsToSearch.append(textFieldIngredient2.text!)
        } else if textFieldIngredient3.text != "" {
            ingredientsToSearch.append(textFieldIngredient3.text!)
        }
        
        if !ingredientsToSearch.isEmpty {
            performSegue(withIdentifier: "SearchIngredientsSegue", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please enter at least 1 ingredient!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    var ingredientsToSearch = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var returnValue: Bool = false
        if !ingredientsToSearch.isEmpty {
            returnValue = true
        }
        return returnValue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        if segue.identifier == "SearchIngredientsSegue" {
            let controller = nav.topViewController as! SearchIngredientsResultTableViewController
            controller.ingredientsToSearch = ingredientsToSearch
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
