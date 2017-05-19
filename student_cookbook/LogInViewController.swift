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
import FacebookLogin
import FBSDKLoginKit

class LogInViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GIDSignInDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {
    
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
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        
        currentStoryboard = self.storyboard
        self.currentStoryboardName = currentStoryboard.value(forKey: "name") as! String
        
        textFieldLoginEmail.layer.cornerRadius = 5.0
        textFieldLoginPassword.layer.cornerRadius = 5.0
        
        addToolBar(textField: textFieldLoginEmail)
        addToolBar(textField: textFieldLoginPassword)
        
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        loginButton.readPermissions = ["email", "public_profile"]
        loginButton.frame = CGRect(x: 46.8, y: 481, width: 150, height: 44)
        loginButton.delegate = self
 
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
       
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
    
    
    @IBAction func buttonRegister(_ sender: UIButton){
        performSegue(withIdentifier: "RegisterSegue", sender: nil)
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
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        let accessToken = FBSDKAccessToken.current()
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: (accessToken?.tokenString)!)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Somethign wrong with user", error ?? "")
                return
            }
            print("Logged in with user")
            self.performSegue(withIdentifier: "UserLoginSegue", sender: nil)
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            print(result ?? "")
        }
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
