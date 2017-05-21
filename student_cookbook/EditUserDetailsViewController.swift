//
//  EditUserDetailsViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 26/04/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class EditUserDetailsViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    var userID: String!
    var user: User?
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var textFieldFirstName: UITextField!
    @IBOutlet weak var textFieldLastName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = user?.userID
        self.ref = FIRDatabase.database().reference()
        
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        profilePicture.makeImageCircle()
        self.dismissKeyboardWhenTappedAround()
        self.dismissKeyboard()

        fillData()
        setUpToolBar()
    }
    
    func fillData(){
        
        textFieldFirstName.text = user?.firstName
        textFieldLastName.text = user?.lastName
        
        let imageURL = user?.profilePicURL
        profilePicture.loadImageWithCacheWithUrlString(imageURL!)
        
    }
    
    
    @IBAction func buttonBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonSave(_ sender: Any) {
        
        editUserDetails(completion: {
            result in
            if result {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadUserData"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    func editUserDetails(completion: @escaping (Bool) -> ()) {
        
        let userRef = ref.child("Users").child(userID)
        
        var photoImageURL: String = ""
        photoImageURL.storeImage(image: profilePicture.image) {
            (result: String) in
            if !result.isEmpty {
                photoImageURL = result
                
                userRef.updateChildValues([
                    "ProfileImageURL": photoImageURL,
                    "FirstName": self.textFieldFirstName.text!,
                    "LastName": self.textFieldLastName.text!])
                completion(true)
            }
        }
    }
    
    
    
    func setUpToolBar(){
        addToolBar(textField: textFieldFirstName)
        addToolBar(textField: textFieldLastName)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/*
 
 func fetchUserData(){
 DispatchQueue.main.async {
 
 self.ref = FIRDatabase.database().reference()
 
 /*
 self.refHandle = self.ref.observe(FIRDataEventType.value, with: { (snapshot) in
 let dataDict = snapshot.value as! NSDictionary
 
 
 print(dataDict)
 }) */
 
 let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
 self.ref.child("Users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
 
 let user = User()
 let snapshotValue = snapshot.value as? NSDictionary
 print(snapshotValue!)
 user.firstName = snapshotValue?["FirstName"] as? String
 user.lastName = snapshotValue?["LastName"] as? String
 user.email = snapshotValue?["Email"] as? String
 user.profilePicURL = snapshotValue?["ProfileImageURL"] as? String
 
 self.nameLabel.text = "\(user.firstName!) \(user.lastName!)"
 self.emailLabel.text = user.email
 if let userProfileURL = user.profilePicURL {
 self.imageViewProfilePic.loadImageWithCacheWithUrlString(userProfileURL)
 }
 })
 }
 }
 } */

