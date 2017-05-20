//
//  Messages.swift
//  student_cookbook
//
//  Created by Jade Redworth on 20/05/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation

class Messages: NSObject {

    var messageID: String!
    var recipeID: String!
    var recipeName: String!
    var recipeImageURL: String!
    var date: String!
    var addedBy: String!
    var decision: String!
    var comment: String!
    var opened: Bool!


    override init(){
    
    }

    init(messageID: String, recipeID: String, recipeName: String, recipeImageURL: String, date: String, addedBy: String, decision: String, comment: String, opened: Bool) {
        self.messageID = messageID
        self.recipeID = recipeID
        self.recipeName = recipeName
        self.recipeImageURL = recipeImageURL
        self.date = date
        self.addedBy = addedBy
        self.decision = decision
        self.comment = comment
        self.opened = opened
    }
}
