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

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    var adminStatus: Bool = false
    
    @IBOutlet weak var textFieldRegisterFName: UITextField!
    @IBOutlet weak var textFieldRegisterLName: UITextField!
    @IBOutlet weak var textFieldRegisterEmail: UITextField!
    @IBOutlet weak var textFieldRegisterAge: UITextField!
    @IBOutlet weak var textFieldRegisterGender: UITextField!
    @IBOutlet weak var textFieldRegisterLocation: UITextField!
    @IBOutlet weak var textFieldRegisterPassword: UITextField!
    @IBOutlet weak var textFieldRegisterRePassword: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var buttonRegister: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        buttonRegister.layer.cornerRadius = 5
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
        if (self.textFieldRegisterPassword.text?.characters.count)! >= 6 {
            
            if self.textFieldRegisterPassword.text! == self.textFieldRegisterRePassword.text! {
                
                let checkedPassword: String = textFieldRegisterRePassword.text!
                
                let uniqueProfilePictureName = UUID().uuidString
                let storageRef = FIRStorage.storage().reference().child("user_profile_images").child("\(uniqueProfilePictureName).png")
                
                
                  let imageToUpload = profilePicture.image?.scaleImageToSize(img: profilePicture.image!, size: CGSize(width: 200.0, height: 200.0))
                
                if let uploadData = UIImagePNGRepresentation(imageToUpload!) {
                    
                    storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                            
                            FIRAuth.auth()?.createUser(withEmail: self.textFieldRegisterEmail.text!, password: checkedPassword, completion: { (user, error) in
                                if error == nil {
                                    self.dismiss(animated: true, completion: nil)
                                    print("User regstered..")
                                } else {
                                    // add alert
                                    print(error!.localizedDescription)
                                }
                                let userID: String = user!.uid
                                let userEmail: String = self.textFieldRegisterEmail.text!
                                let userFName: String = self.textFieldRegisterFName.text!
                                let userLName: String = self.textFieldRegisterLName.text!
                                let userAge: Int = Int(self.textFieldRegisterAge.text!)!
                                let userGender: String = self.textFieldRegisterGender.text!
                                let userLocation: String = self.textFieldRegisterLocation.text!
                                
                                let userPassword: String = checkedPassword
                                
                                self.ref.child("Users").child(userID).setValue(["Email": userEmail, "FirstName": userFName, "LastName": userLName, "Age" : userAge, "Gender" : userGender, "Location" : userLocation, "Password": userPassword, "ProfileImageURL": profileImageURL, "Admin": self.adminStatus])
                            })
                        }
                    })
                }
            } else {
                //TODO alert
            }
        } else {
            //TODO alert
        }
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        profilePicture.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Actions
    
    // Select photo from photo library
    @IBAction func selectPhotoFromLibrary(_ sender: UITapGestureRecognizer) {
        
        print("imagePressed")
        
        let imagePickerController = UIImagePickerController()
        
        // only allows photos to be picked --> TODO allow user to take photos
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
}
