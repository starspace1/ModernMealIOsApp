//
//  ItemOfflineStored.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 1/7/16.
//  Copyright © 2016 Pedro Trujillo. All rights reserved.
//

import Foundation
import CoreData

class ItemOfflineStored: NSManagedObject
{

    var dictionary: NSDictionary!// = NSDictionary()
    
    var id:Int!
    var grocery_list_id:Int!
    var category: String!
    var text: String!
    var recipe_id:String!
    var recipe_name:String!
    var shopped:Bool = false
    var item_name:String!
    var created_at:String!
    var updated_at:String!
    
    
    

    
    func setItemAttributes()//aDictionary:NSDictionary)
    {
        dictionary = api.parseJSONStringToNSDictionary(itemDictionarystring!)
        
        let ItemDict:NSDictionary = dictionary.mutableCopy() as! NSDictionary
        
        if let newID:NSNumber = ItemDict["id"] as? NSNumber
        {
            id = Int(newID)
        }
        
        if let newGrocery_list_id:NSNumber = ItemDict["grocery_list_id"] as? NSNumber
        {
            grocery_list_id = Int(newGrocery_list_id)
        }
        
        
        
        //        recipe_id = nil
        if let newRecipe_id:String = ItemDict["recipe_id"] as? String ?? ""//Int(ItemDict["recipe_id"] as! NSNumber)
        {
            recipe_id  = newRecipe_id
        }
        
        category = ItemDict["category"] as! NSString as String
        text = ItemDict["text"] as! NSString as String
        recipe_name = ItemDict["recipe_name"] as! NSString as String
        shopped = ItemDict["shopped"] as! Bool
        item_name = ItemDict["item_name"] as! NSString as String
        
        created_at = ItemDict["created_at"] as! NSString as String
        updated_at = ItemDict["updated_at"] as! NSString as String
        
        
    }
    
    func getTotalNumberOfCharacters() -> Int
    {
        return Int(text.characters.count + recipe_name.characters.count)
    }
    
    func getTotalNumberOfLinesTexTLabel() -> Int
    {
        
        return Int(Int(text.characters.count)/30)
    }
    
    func getTotalNumberOfLinesDetailLabel() -> Int
    {
        return Int(Int(recipe_name.characters.count)/30)
    }
    
//    func setAllAttributesInDictionary()
//    {
        //         comment lines is because the app just modify one key
        //        dictionary.setValue(id, forKey: "id")
        //        dictionary.setValue(recipe_id, forKey: "recipe_id")
        
        //        dictionary.setValue(grocery_list_id as NSNumber, forKey: "grocery_list_id")
        //        dictionary.setValue(category as NSString, forKey: "category")
        //        dictionary.setValue(text as NSString, forKey: "text")
        //        dictionary.setValue(recipe_name as NSString, forKey: "recipe_name")
//        dictionary.setValue(shopped, forKey: "shopped")
        //        dictionary.setValue(item_name as NSString, forKey: "item_name")
        //        dictionary.setValue(updated_at as NSString, forKey: "updated_at")
        //        dictionary.setValue(created_at as NSString, forKey: "created_at")
        //
//    }
    
//    func getDictionary() -> NSDictionary
//    {
//        setAllAttributesInDictionary()
//        return dictionary
//    }

}
