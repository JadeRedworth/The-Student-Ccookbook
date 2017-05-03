//
//  UserAccountViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 04/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    var userID: String!
    var userList = [User]()
    var user: User?
    
    @IBOutlet weak var imageViewProfilePic: UIImageView!
    //Label Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var noAddedRecipesLabel: UILabel!
    @IBOutlet weak var noRatedRecipesLabel: UILabel!
    @IBOutlet weak var noCookedRecipesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        userID = (FIRAuth.auth()?.currentUser?.uid)!
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        fetchUserData()
    }
    
    func reloadData() {
        fetchUserData()
    }
    
    func fetchUserData(){
        userList.fetchUsers(refName: "Users", queryKey: userID, queryValue: "" as AnyObject, ref: ref) {
            (result: [User]) in
            if result.isEmpty {
                self.userList = []
            } else {
                self.userList = result
                self.user = self.userList[0]
                self.nameLabel.text = "\(self.user!.firstName!) \(self.user!.lastName!)"
                self.emailLabel.text = self.user!.email!
                self.ageLabel.text = "\(self.user!.age!) years"
                self.genderLabel.text = self.user?.gender
                self.locationLabel.text = self.user?.location
                if let userProfileURL = self.user?.profilePicURL {
                    self.imageViewProfilePic.loadImageWithCacheWithUrlString(userProfileURL)
                    self.imageViewProfilePic.makeImageCircle()
                    self.imageViewProfilePic.contentMode = .scaleAspectFill
                }
            }
        }
    }


    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nav = segue.destination as! UINavigationController
        
        if segue.identifier == "EditAccountDetailsSegue" {
            let controller = nav.topViewController as! EditUserDetailsViewController
                controller.user = self.user
        }
    }
    
}
