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

class HomepageViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    
    var currentStoryboard: UIStoryboard!
    var currentStoryboardName: String!
    
    var loggedInSuccessfully: Bool = false
    var adminStatus: Bool = false
    
    @IBOutlet weak var imageViewBackground: UIImageView!
    
    //Button outlets
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonRegister: UIButton!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        loginButton.readPermissions = ["email", "public_profile"]
        loginButton.frame = CGRect(x: 52, y: 360, width: 311, height: 44)
        loginButton.delegate = self
        loginButton.layer.cornerRadius = 5.0
        
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        currentStoryboard = self.storyboard
        self.currentStoryboardName = currentStoryboard.value(forKey: "name") as! String
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
    
    
    // button for log in
    @IBAction func buttonLogin(_ sender: UIButton){
       performSegue(withIdentifier: "LoginSegue", sender: nil)
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
