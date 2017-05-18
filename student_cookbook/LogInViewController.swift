//
//  ViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 04/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class LogInViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    
    var currentStoryboard: UIStoryboard!
    var currentStoryboardName: String!
    
    var loggedInSuccessfully: Bool = false
    var adminStatus: Bool = false
    
    @IBOutlet weak var imageViewBackground: UIImageView!
    
    //Textfields for Login
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    //Button outlets
    @IBOutlet weak var buttonLogin: UIButton!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        currentStoryboard = self.storyboard
        self.currentStoryboardName = currentStoryboard.value(forKey: "name") as! String
        
        textFieldLoginEmail.layer.cornerRadius = 5.0
        textFieldLoginPassword.layer.cornerRadius = 5.0
        
        addToolBar(textField: textFieldLoginEmail)
        addToolBar(textField: textFieldLoginPassword)


    }
    
    // button for log in
    @IBAction func buttonLogin(_ sender: UIButton){
        FIRAuth.auth()?.signIn(withEmail: textFieldLoginEmail.text!, password: textFieldLoginPassword.text!, completion: { (user: FIRUser?, error) in
            if error == nil {
                print("User logged in..")
                self.loggedInSuccessfully = true
                
                let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
                self.ref.child("Users").child(userID).observe(.value, with: { (snapshot) in
                    let userDict = snapshot.value as? NSDictionary
                    if let userType: String = userDict?["UserType"] as? String {
                        if userType == "Admin" {
                            self.adminStatus = true
                        }
                    }
                
                    if self.currentStoryboardName == "Main" {
                         self.performSegue(withIdentifier: "UserLoginSegue", sender: nil)
                    } else {
                        if self.adminStatus == true {
                            self.performSegue(withIdentifier: "AdminLoginSegue", sender: nil)
                        } else {
                            let alertController = UIAlertController(title: "Error", message: "This account is not registered to an administrator, only admin are authorised!", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                            self.loggedInSuccessfully = false
                        }
                    }
                })
            } else {
                let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                self.loggedInSuccessfully = false
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var returnValue: Bool = false
        if identifier == "UserLoginSegue" || identifier == "AdminLoginSegue" {
            if loggedInSuccessfully == false {
                returnValue = false
            } else {
                returnValue = true
            }
        } else if identifier == "RegisterSegue" {
            returnValue = true
        }
        return returnValue
    }
}
