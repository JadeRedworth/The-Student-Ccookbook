//
//  Recipe.swift
//  student_cookbook
//
//  Created by Jade Redworth on 04/03/2017.
//  Copyright © 2017 Jade Redworth. All rights reserved.
//

import Foundation
import UIKit

class Recipes: NSObject {
    
    var id: String?
    var name: String?
    var imageURL: String?
    var addedBy: String?
    var cookTimeHour: Int?
    var cookTimeMinute: Int?
    var prepTimeHour: Int?
    var prepTimeMinute: Int?
    var servingSize: Int?
    var course: String?
    var type: String?
    var approved: Bool?
    var addedByAdmin: Bool?
    var ingredients = [Ingredients]()
    var steps = [Steps]()
    
    override init(){
        
    }
    
    init(id: String, name: String, imageURL: String, addedBy: String, cookTimeHour: Int, cookTimeMin: Int, prepTimeHour: Int, prepTimeMin: Int, servingSize: Int, course: String, type: String, approved: Bool?, addedByAdmin: Bool?, ingredients: [Ingredients], steps: [Steps]) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.addedBy = addedBy
        self.cookTimeHour = cookTimeHour
        self.cookTimeMinute = cookTimeMin
        self.prepTimeHour = prepTimeHour
        self.prepTimeMinute = prepTimeMin
        self.servingSize = servingSize
        self.course = course
        self.type = type
        self.approved = approved
        self.addedByAdmin = addedByAdmin
        self.ingredients = ingredients
        self.steps = steps
    }
    
    class func generateModelArray(_ recipeList: [Recipes]) -> [Recipes]{
        var recipeArray = [Recipes]()
        
        for i in 0..<recipeList.count {
            recipeArray.append(Recipes(
                id: recipeList[i].id!,
                name: recipeList[i].name!,
                imageURL: recipeList[i].imageURL!,
                addedBy: recipeList[i].addedBy!,
                cookTimeHour: recipeList[i].cookTimeHour!,
                cookTimeMin: recipeList[i].cookTimeMinute!,
                prepTimeHour: recipeList[i].prepTimeHour!,
                prepTimeMin: recipeList[i].prepTimeMinute!,
                servingSize: recipeList[i].servingSize!,
                course: recipeList[i].course!,
                type: recipeList[i].type!,
                approved: recipeList[i].approved,
                addedByAdmin: recipeList[i].addedByAdmin,
                ingredients: recipeList[i].ingredients,
                steps: recipeList[i].steps))
        }
        return recipeArray
    }
}
