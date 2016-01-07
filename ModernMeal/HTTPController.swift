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
    private var token: String!
    var signedIn: Bool = false
    
    private var email: String = ""
    private var psw: String = ""
    
    var delegator: HTTPControllerProtocol!
    
    var historyItemsArray: NSMutableArray = []
    
    init(delegate:HTTPControllerProtocol)//,user:String, psw:String)
    {
        self.delegator = delegate
    }
    
    func setToken(tok:String)
    {
        token = tok
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
//            let requestData = ["email": "tazvin2@gmail.com", "password":"password"] // here I modify the json dict in whit the new information
            
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
    func create(var groceryListItem:Item) -> Bool
    {
        var result = false
        
        var tit = "Error adding \(groceryListItem.text!)!"
        var msj = "This item was added at \(groceryListItem.category)  but can not be created in the Modernmeal server because there is a problem with the Internet connection. The grocery list will be updated once the Internet connection is restored"
        
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
                                
                                tit = "\(groceryListItem.text!) was created!"
                                msj = "This item was added to \(groceryListItem.category) in your grocery list."
                                
                                
                                let item:Item = Item(ItemDict: postDataDict["grocery_list_item"] as! NSDictionary)
                                groceryListItem = item
                                
//                                let aVC = viewController as! AddItemViewController
//                                aVC.createItem(item)
                                self.delegator.createItem(item)
                                
                                
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
                        
                        if error!.code == -1009
                        {
                            tit = "\(groceryListItem.text!) can't be created"
                            msj = error!.localizedDescription
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(),
                    {
                        self.delegator.msgResponse(tit, message: msj)
                    })
            }
            createTask.resume()
        }
        
        return result
    }
    
    //MARK: - Update item in grocery list at server
    func update(var groceryListItem:Item) -> Bool
    {
        var result = false
        
        var tit = "Error updating \(groceryListItem.item_name!)!"
        var msj = "This item was updated at \(groceryListItem.category) but can not be updated in the Modernmeal server because there is a problem with the Internet connection. The grocery list will be updated once the Internet connection is restored"
        
        if signedIn
        {
            let fullUrl = "\(baseUrl)/api/v1/grocery_list_items/\(groceryListItem.id!)?auth_token="+token
            let request = NSMutableURLRequest(URL: NSURL(string: fullUrl)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPMethod = "PUT"
            
            
//            let updateData = ["grocery_list_item":groceryListItem.getDictionary()]
            let updateData = ["grocery_list_item":["shopped": groceryListItem.shopped, "text":groceryListItem.text, "category":groceryListItem.category]]
            
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
                        
                        do
                        {
                            let postData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                            if let postDataDict:NSDictionary = (postData as! NSDictionary)
                            {
                                
                                
                                print("--- posData:")
                                print(postData)
                                
                                tit = "\(groceryListItem.item_name!) was updated!"
                                msj = "This item was updated at \(groceryListItem.category) in your grocery list."
                                
                                
                                let item:Item = Item(ItemDict: postDataDict["grocery_list_item"] as! NSDictionary)
                                groceryListItem = item
                                
//                                let aVC = viewController as! AddItemViewController
//                                aVC.createItem(item)
                                self.delegator.updateItem(item)
                                
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
                        
                        if error!.code == -1009
                        {
                            tit = "\(groceryListItem.text!) will be updated"
                            msj = error!.localizedDescription + tit + " once Internet connection is restored"
                            
                            self.historyItemsArray.addObject(groceryListItem)
                        }
                        
                    }
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            self.delegator.msgResponse(tit, message: msj)
                    })
            }
            updateDataTask.resume()
        }
        return result
        
    }
    
    //MARK: - Delete item in grocery list at server
    func delete(groceryListItem:Item) -> Bool
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
                        
                        if error!.code == -1009
                        {
                            let tit = "\(groceryListItem.text!) will be deleted"
                            let msj = error!.localizedDescription + tit + " once Internet connection is restored"
                            
                            self.historyItemsArray.addObject(groceryListItem)

                            dispatch_async(dispatch_get_main_queue(),
                            {
                                    self.delegator.msgResponse(tit, message: msj)
                            })
                            //                        dispatch_async(dispatch_get_main_queue(),
                            //                        {
                            //                        self.delegator.msgResponse("Error deleting \(groceryListItem.item_name)!", message: "This item was deleted at \(groceryListItem.category)  but can not be deleted in the Modernmeal server because there is a problem with the Internet connection. The grocery list will be updated once the Internet connection is restored")
                            //                        })
                        }
  
                    }
                    
            }
            deleteTask.resume()
        }
            return result
    }
    
    func historyStoredTSynchronization()
    {
        if historyItemsArray.count > 0
        {
            let groceryListItem:Item = historyItemsArray.firstObject as! Item
        
            if signedIn
            {
                let fullUrl = "\(baseUrl)/api/v1/grocery_list_items/\(groceryListItem.id)?auth_token="+token
                let request = NSMutableURLRequest(URL: NSURL(string: fullUrl)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                request.HTTPMethod = groceryListItem.method
                
                var genericData = groceryListItem.getDictionary()

                if groceryListItem.method == "PUT"
                {
                    genericData = ["grocery_list_item":["shopped": groceryListItem.shopped, "text":groceryListItem.text, "category":groceryListItem.category]]
                }
             
                do
                {
                    let postData = try NSJSONSerialization.dataWithJSONObject(genericData, options: NSJSONWritingOptions.PrettyPrinted)
                    request.HTTPBody = postData
                }
                catch let error as NSError
                {
                    print("data couldn't be parsed in genericTransaction: \(error)")
                }
                
                let session = NSURLSession.sharedSession()
                let genericTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) // here I send the json file modified
                {
                        data, response, error -> Void in
                        
                    if error == nil
                    {
                        print("item was done, response: \(response)")
                        
                        do
                        {
                            let postData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                            if let postDataDict:NSDictionary = (postData as! NSDictionary)
                            {
                                print("--- posData:")
                                print(postData)
//                                self.historyItemsArray.removeObject(groceryListItem)
                                self.historyItemsArray.removeObjectAtIndex(0)
                                self.historyStoredTSynchronization()
                            }
                        }
                        catch let error as NSError
                        {
                            print("data couln't be parsed in sign in genericTask: \(error)")
                        }
                    }
                    else
                    {
                        print("item error sendig stored item, error: \(error?.localizedDescription)")
                        
                        if error!.code == -1009
                        {
//                            var tit = "\(groceryListItem.text!) will be deleted"
//                            var msj = error!.localizedDescription + tit + " once Internet connection is restored"
//                                dispatch_async(dispatch_get_main_queue(),
//                                {
//                                        self.delegator.msgResponse(tit, message: msj)
//                                })
                        }
                    }
                }
                genericTask.resume()
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),
                {
                    api.getListOfGroceryListsFromAPIModernMeal(self.token)
                    
            })
        }

    }
    

}