//
//  UserShoppingListTableViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 02/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UserShoppingListTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    var userID: String?
    var shoppingList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        userID = (FIRAuth.auth()?.currentUser?.uid)!
        
        getShoppingList()
        self.tableView.reloadData()
    }
    
    func getShoppingList(){
        ref.child("Users").child(self.userID!).child("ShoppingList").observe(.value, with: { (snapshot) in
            
            let shoppingDict: [String] = snapshot.value as! [String]
            
            for i in 0..<shoppingDict.count {
                var item: String = ""
                item = shoppingDict[i]
                self.shoppingList.append(item)
                self.tableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListCell", for: indexPath)
        
        cell.textLabel?.text = shoppingList[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete){
        
            shoppingList.remove(at: indexPath.row)
            self.ref.child("Users").child(userID!).child("ShoppingList").setValue(shoppingList)
        }
    }
}
