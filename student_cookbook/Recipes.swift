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
    var dateAdded: String?
    var difficulty: Int?
    var course: Course?
    var type: String?
    
    var cookTimeHour: Int?
    var cookTimeMinute: Int?
    var prepTimeHour: Int?
    var prepTimeMinute: Int?
    var servingSize: Int?
    var averageRating: Int?
    
    var approved: Bool?
    var addedByAdmin: Bool?
   
    var ingredients = [Ingredients]()
    var steps = [Steps]()
    var reviews = [RecipeReviews]()
    var ratings = Ratings()
    
    enum Course: String {
        case Breakfast
        case Lunch
        case Dinner
        case Dessert
        case All
    }
    
    override init() {
        
    }
    
    init(id: String, name: String, imageURL: String, addedBy: String, dateAdded: String, difficulty: Int, cookTimeHour: Int, cookTimeMin: Int, prepTimeHour: Int, prepTimeMin: Int, servingSize: Int, averageRating: Int, course: Course, type: String, approved: Bool?, addedByAdmin: Bool?, ingredients: [Ingredients], steps: [Steps], reviews: [RecipeReviews], ratings: Ratings) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.addedBy = addedBy
        self.dateAdded = dateAdded
        self.difficulty = difficulty
        self.cookTimeHour = cookTimeHour
        self.cookTimeMinute = cookTimeMin
        self.prepTimeHour = prepTimeHour
        self.prepTimeMinute = prepTimeMin
        self.servingSize = servingSize
        self.averageRating = averageRating
        self.course = course
        self.type = type
        self.approved = approved
        self.addedByAdmin = addedByAdmin
        self.ingredients = ingredients
        self.steps = steps
        self.reviews = reviews
        self.ratings = ratings
     
    }
    
    class func generateModelArray(_ recipeList: [Recipes]) -> [Recipes]{
        var recipeArray = [Recipes]()
        
        for i in 0..<recipeList.count {
            recipeArray.append(Recipes(
                id: recipeList[i].id!,
                name: recipeList[i].name!,
                imageURL: recipeList[i].imageURL!,
                addedBy: recipeList[i].addedBy!,
                dateAdded: recipeList[i].dateAdded!,
                difficulty: recipeList[i].difficulty!,
                cookTimeHour: recipeList[i].cookTimeHour!,
                cookTimeMin: recipeList[i].cookTimeMinute!,
                prepTimeHour: recipeList[i].prepTimeHour!,
                prepTimeMin: recipeList[i].prepTimeMinute!,
                servingSize: recipeList[i].servingSize!,
                averageRating: recipeList[i].averageRating!,
                course: recipeList[i].course!,
                type: recipeList[i].type!,
                approved: recipeList[i].approved,
                addedByAdmin: recipeList[i].addedByAdmin,
                ingredients: recipeList[i].ingredients,
                steps: recipeList[i].steps,
                reviews: recipeList[i].reviews,
                ratings: recipeList[i].ratings))
        }
        return recipeArray
    }
}
