//
//  GroceryList.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/14/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import Foundation
import CoreData

class GroceryList: NSManagedObject
{

//MARK - Atributes
    
    var id:Int!
    var updated_at:NSString!
    var grocery_list_items:Array<NSDictionary>!
    
    
    
    
//MARK: - Getters
    
    
    func getGroceryListJSONAsNSDictionary() -> NSDictionary?
    {
        if let groceryListDict:NSDictionary = api.parseJSONStringToNSDictionary(self.groceryListJSON!)!
        {
            return groceryListDict.mutableCopy() as! NSDictionary
        }
        return nil
    }
    
    //=============================================================================================
    
    //MARK: - grocery_list
    
    
    
    func get_grocery_list() -> NSDictionary?
    {
        if let groceryListDict:NSDictionary = getGroceryListJSONAsNSDictionary()
        {
            if let grocery_list:NSDictionary = groceryListDict["grocery_list"] as? NSDictionary
            {
                return grocery_list
            }
        }
        return nil
    }
    
    func get_created_at() -> NSString?
    {
        if let grocery_list = get_grocery_list()
        {
            if let created_at:NSString = grocery_list["created_at"] as? NSString
            {
                return created_at
            }
        }
        return nil
    }
    
    func get_updated_at() -> NSString?
    {
        if let grocery_list = get_grocery_list()
        {
            if let updated_at_string:NSString = grocery_list["updated_at"] as? NSString
            {
                return updated_at_string
            }
        }
        return nil
    }
    
    func get_id() -> Int?
    {
        if let grocery_list = get_grocery_list()
        {
            if let id_int:Int =  Int(grocery_list["id"] as! NSNumber)
            {
                return id_int
            }
        }
        return nil
    }
    
    func get_grocery_list_item_ids() -> Array<NSNumber>?
    {
        
        if let grocery_list:NSDictionary = get_grocery_list()
        {
            if let grocery_list_item_ids:Array = grocery_list["grocery_list_item_ids"] as! NSArray as? Array<NSNumber>
            {
                return grocery_list_item_ids
            }
        }
        
        return nil
    }
    
    func get_category_order() -> String?
    {
        
        if let grocery_list:NSDictionary = get_grocery_list()
        {
            if let category_order:String = grocery_list["category_order"] as! NSString as String
            {
                return category_order
            }
        }
        
        return nil
    }
    
    func get_name() -> String?
    {
        
        if let grocery_list:NSDictionary = get_grocery_list()
        {
            if let name:String = grocery_list["name"] as! NSString as String
            {
                return name
            }
        }
        
        return nil
    }
    
    func get_shopped() -> Bool
    {
        
        if let grocery_list:NSDictionary = get_grocery_list()
        {
            if let shopped:Bool = grocery_list["shopped"] as! Bool
            {
                return shopped
            }
        }
        
        return false
        
    }
    
    //=============================================================================================
    
    //MARK: - grocery_list_items
    
    func get_grocery_list_items() -> Array<NSDictionary>?
    {
        
        if let groceryListDict:NSDictionary = getGroceryListJSONAsNSDictionary()
        {
            if let grocery_list_items_:Array = groceryListDict["grocery_list_items"] as! NSArray as? Array<NSDictionary>
            {
                return grocery_list_items_
            }
        }
        
        return nil
    }
    
    
//MARK: - Setters
    
    func setModelAtributes()
    {
        updated_at = get_updated_at()
        id = get_id()
        grocery_list_items = get_grocery_list_items()
        
        
    }
    
    func set_updated_at(date:String)
    {
        if let dictionary:NSDictionary = getGroceryListJSONAsNSDictionary()
        {
            dictionary.setValue(date, forKey: "updated_at")
            groceryListJSON = api.parseJSONNSDictionaryToString(dictionary) as! String
        }
    }
    
    func set_grocery_list_items(list:NSArray)
    {
        if let dictionary:NSDictionary = getGroceryListJSONAsNSDictionary()
        {
            dictionary.setValue(list, forKey: "grocery_list_items")
            groceryListJSON = api.parseJSONNSDictionaryToString(dictionary) as! String
        }
    }
    
    
    
}
