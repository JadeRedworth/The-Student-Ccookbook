//
//  User.swift
//  student_cookbook
//
//  Created by Jade Redworth on 04/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit

class User: NSObject {
    var userID: String?
    var firstName: String?
    var lastName: String?
    var profilePicURL: String?
    var userType: UserType?
    
    enum UserType: String {
        case Admin
        case User
        case All
    }
    
    override init(){
        
    }
    
    init(userID: String, firstName: String, lastName: String, profilePicURL: String, userType: UserType) {
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        self.profilePicURL = profilePicURL
        self.userType = userType
    }
    
    class func generateModelArray(_ userList: [User]) -> [User]{
        var userArray = [User]()
        
        for i in 0..<userList.count {
            userArray.append(User(
                userID: userList[i].userID!,
                firstName: userList[i].firstName!,
                lastName: userList[i].lastName!,
                profilePicURL: userList[i].profilePicURL!,
                userType: userList[i].userType!))
        }
        return userArray
    }

}
