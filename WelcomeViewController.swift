//
//  WelcomeViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 21/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class WelcomeViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    var currentStoryboard: UIStoryboard!
    var userList = [User]()
    var userID: String = ""

    @IBOutlet weak var imageViewProfilePicture: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        ref = FIRDatabase.database().reference()
        
        currentStoryboard = self.storyboard

        userList.fetchUsers(refName: "Users", queryKey: userID, queryValue: "" as AnyObject, ref: ref){
            (result: [User]) in
            if result.isEmpty{
                print("No user")
            } else {
                self.userList = result
                self.labelName.text = "\(self.userList[0].firstName!) \(self.userList[0].lastName!)"
                self.imageViewProfilePicture.loadImageWithCacheWithUrlString(self.userList[0].profilePicURL!)
                self.imageViewProfilePicture.makeImageCircle()
            }
        }
    }

    @IBAction func buttonGo(_ sender: Any) {
        performSegue(withIdentifier: "GoSegue", sender: nil)
    }
    
    @IBAction func buttonNotMe(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        
        let vc = currentStoryboard.instantiateViewController(withIdentifier: "LogInViewController") as! LogInViewController
        vc.loggedInUser = "NotLoggedIn"
        self.present(vc, animated:true, completion:nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
