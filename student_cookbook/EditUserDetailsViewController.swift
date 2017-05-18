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

class EditUserDetailsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    var userID: String!
    var user: User?
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var textFieldFirstName: UITextField!
    @IBOutlet weak var textFieldLastName: UITextField!
    @IBOutlet weak var textFieldAge: UITextField!
    @IBOutlet weak var textFieldGender: UITextField!
    @IBOutlet weak var textFieldLocation: UITextField!
    
    // Picker Lists
    var gender = ["Male","Female","Prefer Not To Say"]
    var age: [String] = []
    
    var pickerView = UIPickerView()
    var datasource = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = user?.userID
        self.ref = FIRDatabase.database().reference()
        
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        profilePicture.makeImageCircle()
        self.dismissKeyboardWhenTappedAround()
        self.dismissKeyboard()

        fillData()
        
        self.age = [Int] (11...99).map{ String($0)}
        
        pickerView.delegate = self
        textFieldAge.inputView = pickerView
        textFieldGender.inputView = pickerView
        
        textFieldAge.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        textFieldGender.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
        

        
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
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadData"), object: nil)
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
                    "LastName": self.textFieldLastName.text!,
                    "Age": Int(self.textFieldAge.text!) ?? 0,
                    "Gender": self.textFieldGender.text!,
                    "Location": self.textFieldLocation.text!])
                completion(true)
            }
        }
    }
    
    
    
    func setUpToolBar(){
        addToolBar(textField: textFieldFirstName)
        addToolBar(textField: textFieldLastName)
    }
    
    func donePressed(sender: UIBarButtonItem) {
        textFieldAge.resignFirstResponder()
        textFieldGender.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func myTargetFunction(textField: UITextField) {
        if textField == textFieldAge {
            datasource = age
            self.pickerView.reloadAllComponents()
        } else if textField == textFieldGender {
            datasource = gender
            self.pickerView.reloadAllComponents()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datasource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return datasource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if datasource == age {
            textFieldAge.text = datasource[row]
        } else if datasource == gender {
            textFieldGender.text = datasource[row]
        }
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

