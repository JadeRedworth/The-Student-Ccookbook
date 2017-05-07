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

class AdminUsersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {

    
    let cellId = "cellId"
    var imageURL: String!
    
    var ref: FIRDatabaseReference!
    var refHandle: FIRDatabaseHandle!
    
    var user = User()
    var userList = [User]()
    var selectedUserList = [User]()
    var filteredUserList = [User]()
    
    var userSelected: Bool = false
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var imageViewUser: UIImageView!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelUserAge: UILabel!
    @IBOutlet weak var labelUserGender: UILabel!
    @IBOutlet weak var labelUserLocation: UILabel!
    @IBOutlet weak var labelUserNoRecipesCooked: UILabel!
    @IBOutlet weak var labelUserNoRecipesAdded: UILabel!
    @IBOutlet weak var labelUserNoRecipesRated: UILabel!

    
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
        
        self.userTableView.register(AdminUserTableViewCell.self, forCellReuseIdentifier: cellId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        getUsers()
        
        self.setupSearchController()
        self.userTableView.reloadData()
    }
    
    func handleLogout() {
        try! FIRAuth.auth()!.signOut()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        present(vc!, animated: true, completion: nil)
    }
    
    func reloadData() {
        getUsers()
        self.userTableView.reloadData()
    }
    
    func getUsers(){
        userList.fetchUsers(refName: "Users", queryKey: "", queryValue: "" as AnyObject, ref: ref) {
            (result: [User]) in
            if result.isEmpty {
                self.userList = []
                self.filteredUserList = self.userList
            } else {
                self.userList = result
                self.filteredUserList = User.generateModelArray(self.userList)
            }
            self.fillData()
            self.userTableView.reloadData()
        }
    }
    
    func fillData() {
        if userSelected != true {
            self.user = self.filteredUserList[0]
        }
        
        labelUserName.text = "\(self.user.firstName!) \(self.user.lastName!)"
        labelUserAge.text = "\(String(describing: self.user.age))"
        labelUserGender.text = self.user.gender
        labelUserLocation.text = self.user.location
        labelUserNoRecipesAdded.text = ""
        labelUserNoRecipesCooked.text = ""
        labelUserNoRecipesRated.text = ""
        imageURL = self.user.profilePicURL
        imageViewUser.loadImageWithCacheWithUrlString(imageURL!)
        
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        userTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = ["All","Admin","Users"]
        searchController.searchBar.delegate = self as UISearchBarDelegate
    }
    
    func filterSearchController(searchBar: UISearchBar){
        guard let scopeString = searchBar.scopeButtonTitles?[searchBar.selectedScopeButtonIndex] else { return }
        let selectedUser = User.UserType(rawValue: scopeString) ?? .All
        let searchText = searchBar.text ?? ""
        
        filteredUserList = userList.filter { user in
            let matchingUser = (selectedUser == .All) || (user.userType == selectedUser)
            let matchingText = (user.firstName?.lowercased().contains(searchText.lowercased()))! || (user.lastName?.lowercased().contains(searchText.lowercased()))! || searchText.lowercased().characters.count == 0
            return matchingUser && matchingText
        }
        
        userTableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchController(searchBar: searchController.searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterSearchController(searchBar: searchBar)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
      let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! AdminUserTableViewCell
        
        self.user = filteredUserList[indexPath.row]
        
        cell.textLabel?.text = "\(user.firstName!) \(user.lastName!)"
        cell.detailTextLabel?.text = "Age: \(user.age!)  Gender: \(user.gender!)"
        
        if user.profilePicURL != nil {
            if let profileImageUrl = user.profilePicURL {
                cell.profileImageView.loadImageWithCacheWithUrlString(profileImageUrl)
            }

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.user = filteredUserList[indexPath.row]
        userSelected = true
        fillData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
