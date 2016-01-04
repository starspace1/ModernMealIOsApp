//
//  HTTPController.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/11/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import Foundation
import UIKit

let baseUrl = "http://mmpro-test.herokuapp.com"//set the url of the site

class HTTPController
{
    
    var request: NSMutableURLRequest!
    //var baseUrl = "http://mmpro-test.herokuapp.com"//set the url of the site
    var token: String!
    var signedIn: Bool = false
    
    private var email: String = ""
    private var psw: String = ""
    

    
    var delegator: HTTPControllerProtocol
    
    init(delegate:HTTPControllerProtocol)//,user:String, psw:String)
    {
        self.delegator = delegate
    }
    
    //MARK: - SignIn session
    func singIn(email:String, password:String)
    {
        if token == nil
        {
            let fullUrl = "\(baseUrl)/sessions/create.json?"
            let request = NSMutableURLRequest(URL: NSURL(string: fullUrl)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPMethod = "POST"
            let requestData = ["email": "leslie.k.brown@gmail.com", "password":"awsedrf"] // here I modify the json dict in whit the new information
            //let requestData = ["email": "tazvin2@gmail.com", "password":"password"] // here I modify the json dict in whit the new information
            
            //let requestData = ["email": email, "password":password] // here I modify the json dict in whit the new information
            

            
            do
            {
                // here is serialazed the dictionary to json before to send
                let postData = try NSJSONSerialization.dataWithJSONObject(requestData, options: NSJSONWritingOptions.PrettyPrinted)
                request.HTTPBody = postData // here is packed like a http request
                
            }
            catch let error as NSError
            {
                print("data couldn't be parsed in sign in post data: \(error)")
            }
            
            let session = NSURLSession.sharedSession()
            let authentificationTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) // here I send the json file modified
                {
                    data, response, error -> Void in
                    if error == nil
                    {
                        do
                        {
                            let postData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                            if let postDataDict:NSDictionary = (postData as! NSDictionary)
                            {
                                self.token = postDataDict["token"] as! NSString as String
                                print("--- token:")
                                print(self.token)
                                print("--- posData:")
                                print(postData)
                                self.signedIn = true
                                self.delegator.didReceiveHTTPResults(self.token)
                            }
                        }
                        catch let error as NSError
                        {
                            print("data couln't be parsed in sign in authentication task: \(error)")
                        }
                        
                    }
            }
            authentificationTask.resume()
        }
        
    }
    
    //MARK: - Create item in grocery list at server
    func create(var groceryListItem:Item,viewController:UIViewController) -> Bool
    {
        var result = false
        
        var tit = "Error adding \(groceryListItem.item_name!)!"
        var msj = "This item was added at \(groceryListItem.category)  but can not be created in the ModernMeal server because there is a problem with the Internet connection. The grocery list will be updated once the Internet connection is restored"
        
        if signedIn
        {
            
            let fullURL = "\(baseUrl)/api/v1/grocery_list_items.json/?auth_token="+token
            let request = NSMutableURLRequest(URL: NSURL(string: fullURL)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPMethod = "POST"

            let createData = ["grocery_list_item":groceryListItem.getDictionary()]
            
            do
            {
                let postData = try NSJSONSerialization.dataWithJSONObject(createData, options: NSJSONWritingOptions.PrettyPrinted)
                request.HTTPBody = postData
                
            }
            catch let error as NSError
            {
                print("data couldn't be parsed in create: \(error)")
            }
            
            let session = NSURLSession.sharedSession()
            let createTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) // here I send the json file modified
                {
                    data, response, error -> Void in
                    if error == nil
                    {
                        print("item was created, response: \(response)")
                        result =  true
                        
                        
                        do
                        {
                            let postData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                            if let postDataDict:NSDictionary = (postData as! NSDictionary)
                            {
                                
                                print("--- posData:")
                                print(postData)
                                
                                tit = "\(groceryListItem.item_name!) was created!"
                                msj = "This item was added to \(groceryListItem.category) in your grocery list."
                                
                                let aVC = viewController as! AddItemViewController
                                
                                let item:Item = Item(ItemDict: postDataDict["grocery_list_item"] as! NSDictionary)
                                groceryListItem = item
                                
                                aVC.createItem(item)
                                
                            }
                        }
                        catch let error as NSError
                        {
                            print("data couln't be parsed in sign in create task: \(error)")
                        }
                        
                    }
                    else
                    {
                        print("item error updating, error: \(error?.localizedDescription)")
                        
                        //IN HERE IS NECESSARY ADD THIS ITEM AT THE HISTORY OF NOT CONNECTION ITEMS at httpController
                        
                    }
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        let popUpAlertController = UIAlertController(title: tit , message: msj, preferredStyle: UIAlertControllerStyle.Alert)
                        popUpAlertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                        viewController.presentViewController(popUpAlertController, animated: true, completion: nil)
                    })
            }
            createTask.resume()
        }
        
        return result
    }
    
    //MARK: - Update item in grocery list at server
    func update(groceryListItem:Item,viewController:UIViewController) -> Bool
    {
        var result = false
        
        var tit = "Error updating \(groceryListItem.item_name!)!"
        var msj = "This item was updated at \(groceryListItem.category) but can not be updated in the ModernMeal server because there is a problem with the Internet connection. The grocery list will be updated once the Internet connection is restored"
        
        if signedIn
        {
            let fullUrl = "\(baseUrl)/api/v1/grocery_list_items/\(groceryListItem.id!)?auth_token="+token
            let request = NSMutableURLRequest(URL: NSURL(string: fullUrl)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPMethod = "PUT"
            
            let updateData = ["grocery_list_item":groceryListItem.getDictionary()]
//            let updateData = ["grocery_list_item":["shopped": groceryListItem.shopped]]
            
            do
            {
                let putData = try NSJSONSerialization.dataWithJSONObject(updateData, options: NSJSONWritingOptions.PrettyPrinted)
                request.HTTPBody = putData
                
            }
            catch let error as NSError
            {
                print("data couldn't be parsed in update: \(error)")
            }
            
            let session = NSURLSession.sharedSession()
            let updateDataTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) // here I send the json file modified
                {
                    data, response, error -> Void in
                    if error == nil
                    {
                        print("item was updated, response: \(response)")
                        result =  true
                        tit = "\(groceryListItem.item_name!) was updated!"
                        msj = "This item was updated at \(groceryListItem.category) in your grocery list."
                        
                        do
                        {
                            let postData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                            if let postDataDict:NSDictionary = (postData as! NSDictionary)
                            {
                                
                                print("--- posData:")
                                print(postData)
                            }
                        }
                        catch let error as NSError
                        {
                            print("data couln't be parsed in sign in update task: \(error)")
                        }
                        
                    }
                    else
                    {
                        print("item error updating, error: \(error?.localizedDescription)")
                        //IN HERE IS NECESSARY ADD THIS ITEM AT THE HISTORY OF NOT CONNECTION ITEMS at httpController

                        
                    }
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            let popUpAlertController = UIAlertController(title: tit , message: msj, preferredStyle: UIAlertControllerStyle.Alert)
                            popUpAlertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                            viewController.presentViewController(popUpAlertController, animated: true, completion: nil)
                    })
            }
            updateDataTask.resume()
        }
        return result
        
    }
    
    //MARK: - Delete item in grocery list at server
    func delete(groceryListItem:Item,viewController:UIViewController) -> Bool
    {
        var result = false
        
        if signedIn
        {
            let fullUrl = "\(baseUrl)/api/v1/grocery_list_items/\(groceryListItem.id)?auth_token="+token
            let request = NSMutableURLRequest(URL: NSURL(string: fullUrl)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPMethod = "DELETE"
            let deleteData = groceryListItem.getDictionary()
            
            do
            {
                let postData = try NSJSONSerialization.dataWithJSONObject(deleteData, options: NSJSONWritingOptions.PrettyPrinted)
                request.HTTPBody = postData
                
            }
            catch let error as NSError
            {
                print("data couldn't be parsed in delete: \(error)")
            }
            
            let session = NSURLSession.sharedSession()
            let deleteTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) // here I send the json file modified
                {
                    data, response, error -> Void in
                   
                    if error == nil
                    {
                        
                        print("item was deleted, response: \(response)")
                        result =  true
                        
                        do
                        {
                            let postData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                            if let postDataDict:NSDictionary = (postData as! NSDictionary)
                            {
                                
                                print("--- posData:")
                                print(postData)
                            }
                        }
                        catch let error as NSError
                        {
                            print("data couln't be parsed in sign in delete task: \(error)")
                        }
                        
                    }
                    else
                    {
                        print("item error deleting, error: \(error?.localizedDescription)")
                        //IN HERE IS NECESSARY ADD THIS ITEM AT THE HISTORY OF NOT CONNECTION ITEMS at httpController

                        let popUpAlertController = UIAlertController(title: "Error deleting \(groceryListItem.item_name)!" , message: "This item was deleted at \(groceryListItem.category)  but can not be created in the ModernMeal server because there is a problem with the Internet connection. The grocery list will be updated once the Internet connection is restored", preferredStyle: UIAlertControllerStyle.Alert)
                        popUpAlertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                        viewController.presentViewController(popUpAlertController, animated: true, completion: nil)
                        
                    }
                 
                    
            }
            deleteTask.resume()
        }
//        dispatch_async(dispatch_get_main_queue(),
//        {
            return result
//        })
        
    }

}