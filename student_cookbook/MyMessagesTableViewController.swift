//
//  MyMessagesTableViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 20/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class MyMessagesTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    var uid: String!
    var i: Int = 0
    var recipeID: String!
    var messageList = [Messages]()
    var unreadMessageList = [Messages]()
    var readMessageList = [Messages]()
    var recipeList = [Recipes]()
    var selectedMessage = Messages()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        uid = FIRAuth.auth()?.currentUser?.uid
        
        if uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        getMessages()
    }
    
    func handleLogout() {
        try! FIRAuth.auth()!.signOut()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
    
    func getMessages(){
        unreadMessageList.fecthMessages(refName: "AdminRecipeComments", queryKey: uid, queryValue: false, ref: ref) {
            (result: [Messages]) in
            if result.isEmpty {
                print("No Messages")
            } else {
                self.unreadMessageList = result
                self.tableView.reloadData()
            }
        }
        
        readMessageList.fecthMessages(refName: "AdminRecipeComments", queryKey: uid, queryValue: true, ref: ref){
            (result: [Messages]) in
            if result.isEmpty { } else {
                self.readMessageList = result
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func buttonBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return unreadMessageList.count
        } else {
            return readMessageList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Unread Messages"
        } else {
            return "Read Messages"
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessagesCell", for: indexPath) as! MyMessagesTableViewCell
        
        var message = Messages()
        
        if indexPath.section == 0 {
            self.messageList = unreadMessageList
            message = unreadMessageList[indexPath.row]
            cell.tintColor = UIColor.blue
        } else {
            self.messageList = readMessageList
            message = readMessageList[indexPath.row]
        }
        
        self.recipeID = message.recipeID
        cell.labelRecipeName.text = message.recipeName
        cell.imageViewRecipe.loadImageWithCacheWithUrlString(message.recipeImageURL)
        cell.imageViewRecipe.makeImageCircle()
        
        cell.labelResult.text = message.decision
        if message.decision == "Approved" {
            cell.labelResult.textColor = UIColor.green
        } else {
            cell.labelResult.textColor = UIColor.red
        }
        cell.labelComment.text = message.comment
        cell.labelDate.text = message.date
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if indexPath.row == 0 {
            if !unreadMessageList.isEmpty {
                self.messageList = self.unreadMessageList
                self.selectedMessage = self.unreadMessageList[indexPath.row]
            }
        } else {
            if !readMessageList.isEmpty{
                self.messageList = readMessageList
                self.selectedMessage = self.readMessageList[indexPath.row]
            }
        }
        
        let markAsRead = UITableViewRowAction(style: .normal, title: "Read") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let messageRef = self.ref.child("AdminRecipeComments").child(self.uid).child(self.messageList[indexPath.row].messageID)
            messageRef.updateChildValues(["Opened" : true])
            self.readMessageList.removeAll()
            self.unreadMessageList.removeAll()
            self.getMessages()
        }
        markAsRead.backgroundColor = UIColor.blue
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action: UITableViewRowAction, indexPath: IndexPath) in
            
            self.i = 0
            let removeMessageRef = self.ref.child("AdminRecipeComments").child(self.uid).child(self.selectedMessage.messageID)
            removeMessageRef.removeValue()
            self.readMessageList.removeAll()
            self.unreadMessageList.removeAll()
            self.getMessages()
        }
        delete.backgroundColor = UIColor.red

        return [delete, markAsRead]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

class MyMessagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewRecipe: UIImageView!
    
    @IBOutlet weak var labelRecipeName: UILabel!
    @IBOutlet weak var labelResult: UILabel!
    @IBOutlet weak var labelComment: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    
    
}
