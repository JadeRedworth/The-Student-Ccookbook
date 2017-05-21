//
//  ViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 04/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn
import FacebookLogin
import FBSDKLoginKit

class LogInViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBSDKLoginButtonDelegate {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    
    var currentStoryboard: UIStoryboard!
    var currentStoryboardName: String!
    
    var loggedInSuccessfully: Bool = false
    var adminStatus: Bool = false
    
    var loggedInUser: String!
    var notMe: Bool = false
    
    @IBOutlet weak var imageViewBackground: UIImageView!
    
    //Textfields for Login
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        currentStoryboard = self.storyboard
        self.currentStoryboardName = currentStoryboard.value(forKey: "name") as! String
        
        // Check if the storyboard is the one associated with the iPhone.
        if currentStoryboardName == "Main" {
            
            // 'notMe' is set to true on the 'WelcomeViewController' if the user selects the 'Not Me' button.
            if notMe == true {
                try! FIRAuth.auth()!.signOut()
            } else {
                loggedInUser = FIRAuth.auth()?.currentUser?.uid
            }
            
            textFieldLoginPassword.underlined()
            textFieldLoginEmail.underlined()
            
            // Facebook button setup.
            let loginButton = FBSDKLoginButton()
            view.addSubview(loginButton)
            loginButton.readPermissions = ["email", "public_profile"]
            loginButton.frame = CGRect(x: 56, y: 617, width: 300, height: 40)
            loginButton.delegate = self

        }
    
        // Adds the toolbar from the extenstion to the text fields.
        addToolBar(textField: textFieldLoginEmail)
        addToolBar(textField: textFieldLoginPassword)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        
        // Check if a user is already logged in, if so redirect to the 'WelcomeViewController'
        if loggedInUser != nil {
            let vc = currentStoryboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
            vc.userID = loggedInUser
            self.present(vc, animated:true, completion:nil)
        } else { }
    }
    
    @IBAction func buttonSkip(_ sender: Any) {
        // Allows guests to continue without registering.
        performSegue(withIdentifier: "GuestUserSegue", sender: nil)
    }
    
    // button for log in
    @IBAction func buttonLogin(_ sender: UIButton){
        
        // Send the email and password to be checked against the emails and passwords in the Firebase
        // Authentication
        FIRAuth.auth()?.signIn(withEmail: textFieldLoginEmail.text!, password: textFieldLoginPassword.text!, completion: { (user: FIRUser?, error) in
            
            // If no error is returned the user is successfully logged in.
            if error == nil {
                print("User logged in..")
                self.loggedInSuccessfully = true
                
                // Retrieves the userID for the signed in user.
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
                
                // Alerts the user of the error.
                let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                self.loggedInSuccessfully = false
            }
        })
    }
    
    
    @IBAction func buttonRegister(_ sender: UIButton){
        // Redirects user to Register Page.
        performSegue(withIdentifier: "RegisterSegue", sender: nil)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    // Facebook Login Setup.
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        // Access Token retrived from Facebook.
        let accessToken = FBSDKAccessToken.current()
        
        // Send the credentials associated with the accessToekn returned from Facebook. These will be checked against the facebook accounts within the Firebase Authentication.
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: (accessToken?.tokenString)!)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            
            if error != nil {
                print("Somethign wrong with user", error ?? "")
                return
            }
            guard let uid = user?.uid else {
                return
            }
            
            
            let userRef = self.ref.child("Users").child(uid)
            
            // Requests the Facebook ID, name and email associated with the logged in facebook account.
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                if error != nil {
                    print(error!)
                } else {
                    
                    // If the parameters are succesfully returned the parameters can be serperated into a dictionary.
                    let resultDict = result as! [String : AnyObject]
                    let fid = resultDict["id"] as? String ?? ""
                    let fullname = resultDict["name"] as? String ?? ""
                    var fullNameArr = fullname.components(separatedBy: " ")
                    let firstName = fullNameArr[0]
                    let lastName = fullNameArr[1]
                    
                    // Requests the profile picture for the Facebook ID. A height and width of 200 are used to obtain the correct sized image.
                    
                    let profilepic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":200, "width":200,"redirect":false], httpMethod: "GET")
                    profilepic?.start(completionHandler: { (connection, result, error) -> Void in

                        if error != nil { } else {
                            

                            // If the image has been successfully returned the image can be uploaded to Firebase
                            // Storage
                            
                            let picDict = result as! [String: AnyObject]
                            let data = picDict["data"]
                            let profilePicURL = data?["url"] as? String ?? ""
                            
                            
                            if let imageData = NSData(contentsOf: URL(string: profilePicURL)!){
                            
                                let uniqueProfilePictureName = UUID().uuidString
                                let storageRef = FIRStorage.storage().reference().child("user_profile_images").child("\(uniqueProfilePictureName).png")
                            
                                _ = storageRef.put(imageData as Data, metadata: nil, completion: { (metadata, error) in
                                    if error != nil {
                                        print(error!)
                                        return
                                    } else {
                                        
                                        // If the image was successfully uploaded to Firebase Storage, the ImageURL 
                                        // can then be downloaded to store in the Firebase Database.
                                        if let downloadURL = metadata?.downloadURL()?.absoluteString {
                                            
                                            // The details retrived from the facebook login account can then be 
                                            
                                            let userValue = (["FirstName": firstName,
                                                              "LastName": lastName,
                                                              "ProfileImageURL": downloadURL,
                                                              "UserType": "User",
                                                              "NoRecipesAdded" : 0,
                                                              "NoRecipesRated" : 0] as [String : Any])
                                            userRef.updateChildValues(userValue, withCompletionBlock: { (error, ref) in
                                                if error != nil {
                                                    print(error!)
                                                    return
                                                }
                                                print("Save the user successfully into Firebase database")
                                                self.performSegue(withIdentifier: "UserLoginSegue", sender: nil)
                                            })
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
            })
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let guestRef = ref.child("GuestUser").childByAutoId()
        guestRef.setValue(["Date": "\(Date())",
                            "Guest": true])
        if segue.identifier == "GuestUserSegue" {
            let tabBarController = segue.destination as! UITabBarController
            let nav = tabBarController.viewControllers?[0] as! UINavigationController
            let controller = nav.topViewController as! RecipeHomeTableViewController
            controller.guestID = guestRef.key
            print(guestRef.key)
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
