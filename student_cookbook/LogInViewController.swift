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
import GoogleSignIn

class LogInViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    
    var currentStoryboard: UIStoryboard!
    var currentStoryboardName: String!
    
    var loggedInSuccessfully: Bool = false
    
    //Textfields for Login
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    //Button outlets
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonRegister: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        currentStoryboard = self.storyboard
        self.currentStoryboardName = currentStoryboard.value(forKey: "name") as! String
        
        buttonLogin.layer.cornerRadius = 5
        buttonRegister.layer.cornerRadius = 5
 
    }
    
    /*
     // Check if user is an admin
     func checkIfUserIsAdmin() -> Bool {
     var result: Bool = false
     DispatchQueue.main.async {
     }
     return result
     } */
    
    
    
    // button for log in
    @IBAction func buttonLogin(_ sender: UIButton){
        FIRAuth.auth()?.signIn(withEmail: textFieldLoginEmail.text!, password: textFieldLoginPassword.text!, completion: { (user: FIRUser?, error) in
            if error == nil {
                print("User logged in..")
                self.loggedInSuccessfully = true
                
                let userID: String = (FIRAuth.auth()?.currentUser?.uid)!
                self.ref.child("Users").child(userID).observe(.value, with: { (snapshot) in
                    let userDict = snapshot.value as? NSDictionary
                    let adminStatus: Bool = userDict!["Admin"] as! Bool
                    
                    if self.currentStoryboardName == "Main" {
                         self.performSegue(withIdentifier: "UserLoginSegue", sender: nil)
                    } else {
                        if adminStatus == true {
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
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print(error!.localizedDescription)
                self.loggedInSuccessfully = false
                return
            }
            print("User logged in with google")
            self.loggedInSuccessfully = true
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        try! FIRAuth.auth()!.signOut()
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
