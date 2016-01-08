//
//  HTTPController.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/11/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let baseUrl = "http://mmpro-test.herokuapp.com"//set the url of the site



class HTTPController
{
    
    var request: NSMutableURLRequest!
    private var token: String!
    var signedIn: Bool = false
    private var username: String!
    
    private var email: String = ""
    private var psw: String = ""
    
    var delegator: HTTPControllerProtocol!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var itemOfflineArray: Array<ItemOfflineStored> = []
    
    init(delegate:HTTPControllerProtocol)//,user:String, psw:String)
    {
        self.delegator = delegate
        
        loadContext()
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
            var tit = "Sorry!"///be careful with this message! it have to be same at the main controller view validation
            var msj = "There is an problem trying to access with \(email) account"
            
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
                                self.username = postDataDict["username"] as! NSString as String
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
                    else
                    {
                        if error!.code == -1009
                        {
                            tit = "Connection error!"///be careful with this message! it have to be same at the main controller view validation
                            msj = error!.localizedDescription + " Try again once Internet connection is restored"
                            
                        }
                        
                        dispatch_async(dispatch_get_main_queue(),
                            {
                                self.delegator.msgResponse(tit, message: msj)
                        })
                        
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
                            
                            groceryListItem.method = "PUT"
                            self.addItemOfflineArray(groceryListItem)
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
                            
                            groceryListItem.method = "DELETE"
                            self.addItemOfflineArray(groceryListItem)

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
        print("FIRST CALL OF historyStoredTSynchronization!!!")

        if itemOfflineArray.count > 0
        {
            let groceryListItem = itemOfflineArray.first!
            groceryListItem.setItemAttributes()
        
            if signedIn
            {
                let fullUrl = "\(baseUrl)/api/v1/grocery_list_items/\(groceryListItem.id)?auth_token="+token
                let request = NSMutableURLRequest(URL: NSURL(string: fullUrl)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                var genericData = [:]
                
                print(" SENDING itemOfflineArray \(groceryListItem.id)")
                
                if groceryListItem.method == "PUT"//"Optional(\"PUT\")"
                {
                    request.HTTPMethod  = "PUT"
                    
                    genericData = ["grocery_list_item":["shopped": groceryListItem.shopped, "text":groceryListItem.text, "category":groceryListItem.category]]
                    print("SYNCRONIZED WITH PUT")

                }
                if groceryListItem.method == "DELETE"//"Optional(\"DELETE\")"
                {
                    request.HTTPMethod  = "DELETE"
                    
                    genericData = groceryListItem.dictionary
                    
                    print("SYNCRONIZED WITH DELETE")
                    
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
                        print("item was done!!, response: \(response)")
                        
                        do
                        {
                            let postData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                            self.itemOfflineArray.removeFirst()
                            self.managedObjectContext.deleteObject(groceryListItem)
                            self.saveContext()
                            
                            self.historyStoredTSynchronization()
                            
                            if let postDataDict:NSDictionary = (postData as! NSDictionary)
                            {
                                print("--- posData:")
                                print(postData)
                                
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
                print("END OF ITEMS OF historyStoredTSynchronization!!!")
                
                    api.getListOfGroceryListsFromAPIModernMeal(self.token)
            })
        }

    }
    
    //===================================================================================================================
    //MARK: - CoreData
    //===================================================================================================================
    
    //MARK: Create new core data ItemOfflineStored object and save it
    func addItemOfflineArray(anItem:Item)
    {
        if let dictionaryString = api.parseJSONNSDictionaryToString(anItem.dictionary) as? String
        {
            // create a new core data object
            let newStoredItem = NSEntityDescription.insertNewObjectForEntityForName("ItemOfflineStored", inManagedObjectContext: managedObjectContext) as! ItemOfflineStored
            
            newStoredItem.itemDictionarystring = dictionaryString
//            newStoredItem.setItemAttributes(anItem.dictionary)
//            newStoredItem.dictionary = anItem.dictionary
            newStoredItem.method = anItem.method
            
//            newStoredItem.setAllAttributesInDictionary() //set instances of each atribute of the model ItemOfflineStored class
            itemOfflineArray.append(newStoredItem)
            print("---- item offline was saved dic: \(newStoredItem.dictionary)")

            saveContext()
        }
    }
    
    //MARK: Load context
    func loadContext() -> Bool
    {
        //fethc the list of task from core data
        let fetchRequest = NSFetchRequest (entityName: "ItemOfflineStored")
        
        do
        {
            //conver the result from coredata in array
            if let fetchRequestResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? Array<ItemOfflineStored>
            {
                // To make equal the array coredata to array<itemOfflineArray>
                itemOfflineArray = fetchRequestResults //<============================
                // print(groceryListsArray)
                if itemOfflineArray.count > 0
                {
                    for ItemOffline in itemOfflineArray
                    {
                        
                        let newItemOffline:ItemOfflineStored = ItemOffline as ItemOfflineStored
                        print("---- item offline dic: \(newItemOffline.dictionary) method: \(newItemOffline.method)")
                        
                    }
                    //print(itemOfflineArray)
                    return true //succes!There is information stored in Core data
                }
                else
                {
                    return false //Is empty Core data
                }
            }
        }
            
        catch
        {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return false //Is empty Core data
    }


    
    //MARK: Save context
    func saveContext()
    {
        do
        {
            try managedObjectContext.save()
        }
        catch
        {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    

    

}