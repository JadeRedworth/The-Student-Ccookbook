//
//  RegisterViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 19/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class RegisterViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    var adminStatus: Bool = false
    
    @IBOutlet weak var textFieldRegisterFName: UITextField!
    @IBOutlet weak var textFieldRegisterLName: UITextField!
    @IBOutlet weak var textFieldRegisterEmail: UITextField!
    @IBOutlet weak var textFieldRegisterPassword: UITextField!
    @IBOutlet weak var textFieldRegisterRePassword: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var buttonRegister: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        self.dismissKeyboardWhenTappedAround()
        self.dismissKeyboard()
    
        ref = FIRDatabase.database().reference()
        
        textFieldRegisterFName.underlined()
        textFieldRegisterLName.underlined()
        textFieldRegisterEmail.underlined()
        textFieldRegisterPassword.underlined()
        textFieldRegisterRePassword.underlined()
        
        addToolBar(textField: textFieldRegisterFName)
        addToolBar(textField: textFieldRegisterLName)
        addToolBar(textField: textFieldRegisterEmail)
        addToolBar(textField: textFieldRegisterPassword)
        addToolBar(textField: textFieldRegisterRePassword)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func buttonBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //button for registration
    @IBAction func buttonRegister(_ sender: UIButton) {
        
        // Check if password fields are more than 6 charcters.
        if (self.textFieldRegisterPassword.text?.characters.count)! >= 6 {
            
            // Check id both password fields are the same.
            if self.textFieldRegisterPassword.text! == self.textFieldRegisterRePassword.text! {
                
                let checkedPassword: String = textFieldRegisterRePassword.text!
                
                let uniqueProfilePictureName = UUID().uuidString
                let storageRef = FIRStorage.storage().reference().child("user_profile_images").child("\(uniqueProfilePictureName).png")
                
                // Scale the image to the correct size to be stored into the Firebase Storage.
                let imageToUpload = profilePicture.image?.scaleImageToSize(img: profilePicture.image!, size: CGSize(width: 200.0, height: 200.0))
                
                if let uploadData = UIImagePNGRepresentation(imageToUpload!) {
                    
                    // Upload the selected profile image to the Firebase Storage.
                    storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        // If image was successfully uploaded, return the URL reference to be stored within the 
                        // Firebase database.
                        if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                            
                            // Send the email and the password to Firebase Authentication to be authenticated.
                            FIRAuth.auth()?.createUser(withEmail: self.textFieldRegisterEmail.text!, password: checkedPassword, completion: { (user, error) in
                                
                                // If successful the user can then be created and stored into the Firebase 
                                // Database.
                                if error == nil {
                                    
                                    let userID: String = user!.uid
                                    let userFName: String = self.textFieldRegisterFName.text!
                                    let userLName: String = self.textFieldRegisterLName.text!
                                    
                                    let userValue = (["FirstName": userFName,
                                                      "LastName": userLName,
                                                      "ProfileImageURL": profileImageURL,
                                                      "UserType": "User",
                                                      "NoRecipesAdded" : 0,
                                                      "NoRecipesRated" : 0] as [String : Any])
                                    self.ref.child("Users").child(userID).setValue(userValue)

                                  
                                    let alertController = UIAlertController(title: "Success", message: "Your account has been successfully registered! :)", preferredStyle: UIAlertControllerStyle.alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alertController, animated: true, completion: nil)
    
                                } else {
                                    let alertController = UIAlertController(title: "Error", message: "Failed to register your account, please try again! :(", preferredStyle: UIAlertControllerStyle.alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alertController, animated: true, completion: nil)
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            } else {
                let alertController = UIAlertController(title: "Error", message: "Passwords do not match!", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "Password must be longer than 6 characters!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
}
