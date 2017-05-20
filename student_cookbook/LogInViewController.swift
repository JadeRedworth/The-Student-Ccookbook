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
    
    @IBOutlet weak var imageViewBackground: UIImageView!
    
    //Textfields for Login
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        
        currentStoryboard = self.storyboard
        self.currentStoryboardName = currentStoryboard.value(forKey: "name") as! String
    
        textFieldLoginPassword.underlined()
        textFieldLoginEmail.underlined()
        
        addToolBar(textField: textFieldLoginEmail)
        addToolBar(textField: textFieldLoginPassword)
        
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        loginButton.readPermissions = ["email", "public_profile"]
        loginButton.frame = CGRect(x: 56, y: 591, width: 300, height: 40)
        loginButton.delegate = self
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
            guard let uid = user?.uid else {
                return
            }
            
            let userRef = self.ref.child("Users").child(uid)
            
            
            print("Logged in with user")
            
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                if error != nil {
                    print(error!)
                } else {
                    let resultDict = result as! [String : AnyObject]
                    let fid = resultDict["id"] as? String ?? ""
                    let fullname = resultDict["name"] as? String ?? ""
                    var fullNameArr = fullname.components(separatedBy: " ")
                    let firstName = fullNameArr[0]
                    let lastName = fullNameArr[1]
                    
                    let profilepic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height":200, "width":200,"redirect":false], httpMethod: "GET")
                    profilepic?.start(completionHandler: { (connection, result, error) -> Void in

                        if error != nil { } else {
                            
                            print(result)
                            
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
                                        if let downloadURL = metadata?.downloadURL()?.absoluteString {
                                            
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
