//
//  AdminUsersTableViewController.swift
//  student_cookbook
//
//  Created by Jade Redworth on 30/04/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

enum userSelectedScope:Int {
    case all = 0
    case female = 1
    case male = 2
    case admin = 3
}

class AdminUsersTableViewController: UITableViewController, UISearchBarDelegate {
    
    let cellId = "cellId"
    
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    
    var userList = [User]()
    var selectedUserList = [User]()
    var filteredUserList = [User]()

    @IBAction func buttonLogout(_ sender: Any) {
        handleLogout()
    }
    
    var userID: String!
       var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.dismissKeyboardWhenTappedAround()
        
        ref = FIRDatabase.database().reference()
        
        uid = FIRAuth.auth()?.currentUser?.uid
        
        if uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        tableView.register(AdminUserTableViewCell.self, forCellReuseIdentifier: cellId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        getUsers()
        
        self.searchBarSetup()
        self.tableView.reloadData()
    }
    
    func handleLogout() {
        try! FIRAuth.auth()!.signOut()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
    
    func reloadData() {
        getUsers()
        self.tableView.reloadData()
    }
    
    func getUsers(){
        userList.fetchUsers(refName: "Users", queryKey: "", queryValue: "" as AnyObject, ref: ref) {
            (result: [User]) in
            if result.isEmpty {
                self.userList = []
                self.filteredUserList = self.userList
                self.tableView.reloadData()
            } else {
                self.userList = result
                self.filteredUserList = User.generateModelArray(self.userList)
                self.tableView.reloadData()
            }
        }
        self.tableView.reloadData()
    }
    
    func searchBarSetup() {
        let searchBar = UISearchBar(frame: CGRect(x:0,y:0,width:(UIScreen.main.bounds.width),height:70))
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = ["All", "Female","Male", "Admin"]
        searchBar.selectedScopeButtonIndex = 0
        searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar
    }
    
    // MARK: - search bar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUserList = userList
            self.tableView.reloadData()
        } else {
            filterTableView(searchBar.selectedScopeButtonIndex, text: searchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 0 {
            filteredUserList = userList
            self.tableView.reloadData()
            
        } else if selectedScope == 1 {
            filteredUserList
                = userList.filter({ (female) -> Bool in
                return (female.gender?.contains("Female"))!
            })
            self.tableView.reloadData()
            selectedUserList = filteredUserList
            
        } else if selectedScope == 2 {
            filteredUserList = userList.filter({ (male) -> Bool in
                return (male.gender?.contains("Male"))!
            })
            self.tableView.reloadData()
            selectedUserList = filteredUserList
            
        } else if selectedScope == 3 {
            filteredUserList = userList.filter({ (admin) -> Bool in
                return (admin.admin == true)
            })
            self.tableView.reloadData()
            selectedUserList = filteredUserList
        }
    }
    
    func filterTableView(_ ind: Int, text: String) {
        switch ind {
        case userSelectedScope.all.rawValue:
            filteredUserList = userList.filter({ (user) -> Bool in
                return (user.firstName?.lowercased().contains(text.lowercased()))! ||
                    (user.lastName?.lowercased().contains(text.lowercased()))!
            })
            self.tableView.reloadData()
            break
            
        case userSelectedScope.female.rawValue:
            filteredUserList = selectedUserList.filter({ (female) -> Bool in
                return (female.firstName?.lowercased().contains(text.lowercased()))! ||
                    (female.lastName?.lowercased().contains(text.lowercased()))!
            })
            self.tableView.reloadData()
            break
            
        case userSelectedScope.male.rawValue:
            filteredUserList = selectedUserList.filter({ (male) -> Bool in
                return (male.firstName?.lowercased().contains(text.lowercased()))! ||
                    (male.lastName?.lowercased().contains(text.lowercased()))!
            })
            self.tableView.reloadData()
            break
            
        case userSelectedScope.admin.rawValue:
            filteredUserList = selectedUserList.filter({ (admin) -> Bool in
                return (admin.firstName?.lowercased().contains(text.lowercased()))! ||
                    (admin.lastName?.lowercased().contains(text.lowercased()))!
            })
            self.tableView.reloadData()
            break

        default:
            print("No Recipes")
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredUserList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
      let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AdminUserTableViewCell
        
        let user = filteredUserList[indexPath.row]
        
        cell.textLabel?.text = "\(user.firstName!) \(user.lastName!)"
        cell.detailTextLabel?.text = "Age: \(user.age!)  Gender: \(user.gender!)"
        
        if user.profilePicURL != nil {
            if let profileImageUrl = user.profilePicURL {
                cell.profileImageView.loadImageWithCacheWithUrlString(profileImageUrl)
            }

        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    /*
     
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     return true
     }
     
     override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
     
     let favorites = UITableViewRowAction(style: .normal, title: "Add To Favourites") { action, index in
     let userRef = self.ref.child("Users").child(self.uid).child("Favourites").childByAutoId()
     let favValue = ["RecipeID": self.filteredRecipeList[indexPath.row].id]
     userRef.setValue(favValue)
     self.showAlert(title: "Success", message: "Recipe has been added to Favourites")
     
     }
     favorites.backgroundColor = UIColor.blue
     
     return [favorites]
     }
     
     */
}



class AdminUserTableViewCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
        
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setCircleSize()
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "UsersCell")
        
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
