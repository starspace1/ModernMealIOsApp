//
//  APIController.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/12/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import Foundation

class APIController:NSURLSessionDataTask, NSURLSessionDelegate, NSURLSessionDataDelegate
{
    var receiveData:NSMutableData!
    var tasksArray:NSMutableArray = []
    var groceryListOfListArray: Array<NSDictionary> = []
    var groceryListOfListDictionary = Dictionary<Int, NSDictionary>()//[Int: NSDictionary]()
    var delegator: APIControllerProtocol
    private var token: String!
    
 
    init(delegate:APIControllerProtocol)
    {
        self.delegator = delegate
    }
    
    func getListOfGroceryListsFromAPIModernMeal(token:String)
    {
        print("doing getListOfGroceryListsFromAPIModernMeal")
        var  arrayListsIds: NSMutableArray = []
        self.token = token

        let urlRequest = baseUrl+"/api/v1/grocery_lists?limit=60&auth_token="+token
        let url:NSURL = NSURL(string: urlRequest)!
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: { data, response, error -> Void in
            print("completed Task getListOfGroceryListsFromAPIModernMeal")
            
            if error != nil
            {
                print(error!.localizedDescription)
                
            }
            else
            {
                if let dictionary = self.parseJSON(data!)
                {
                    
                    if let grocery_list_elements:Array = dictionary["grocery_list_elements"] as! NSArray as? Array<NSDictionary>
                    {
                        
                        
                        for element in grocery_list_elements
                        {
                            if let newDict:NSDictionary = element as NSDictionary
                            {
                                arrayListsIds.addObject(Int(newDict["id"] as! NSNumber))
                                
                            }
                        }
                        
                        self.delegator.didReceiveAPIResults(arrayListsIds)
                        
                    }
                    
                    //print("dictionary parseJSON: \(dictionary)" )
                }
                // print("urlRequestByUser: \(url)")
            }
        })
        task.resume()
        
    }
    
    func getGroceryListFromAPIModernMeal(idListsArray:NSMutableArray)//, token:String)
    {
        for idList in idListsArray
        {
            let urlRequest = baseUrl+"/api/v1/grocery_lists/\(idList)?auth_token="+token
            let url:NSURL = NSURL(string: urlRequest)!
            appendTask(url)
        }
        tasksArray[0].resume()
    }
    
    func appendTask(url:NSURL)
    {
        let sessionConfiguaration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session:NSURLSession = NSURLSession(configuration: sessionConfiguaration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let dataTask:NSURLSessionDataTask = session.dataTaskWithURL(url)
        tasksArray.addObject(dataTask)//.append(dataTask)
    }
    
    
    //MARK - Functions delegated from NSURLSessionDataDelegate
    
     func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void)
    {
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData)
    {
        if receiveData != nil
        {
            receiveData.appendData(data)
        }
        else
        {
            receiveData = NSMutableData(data: data)
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?)
    {
        if error != nil
        {
            print(error!.localizedDescription)
        }
        else
        {
            if receiveData != nil
            {
                if let dictionary = self.parseJSON(receiveData!)
                {
                    groceryListOfListArray.append(dictionary)/// erase it after
                    
                    if let newDict:NSDictionary = dictionary as NSDictionary
                    {
                        print(newDict)
                        self.groceryListOfListDictionary[Int(newDict["grocery_list"]!["id"] as! NSNumber)] = newDict //======error
                    }

                    
                    receiveData = nil // this is necessary to clean de task array for more requests
                    //print("dictionary URLSession parseJSON: \(dictionary)" )
                }
                // print("urlRequestByUser: \(url)")
            }
        }
        
        
        tasksArray.removeObject(task)
        
        if tasksArray.count != 0
        {
            tasksArray[0].resume()
        }
        else
        {
            delegator.didReceiveListOfListsFromAPIResults(groceryListOfListDictionary)
        }
        
        receiveData = nil

    }
    
    

    
    
    //MARK - JSON Serializations and converters
    
    //parse the JSON file to get a Dictionary to use with the app
    func parseJSON(data:NSData) -> NSDictionary?
    {
        do
        {
            let dictionary: NSDictionary! = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
            return dictionary
        }
        catch let error as NSError
        {
            print(error)
            return nil
        }
        
    }
    
    
    func parseJSONStringToNSDictionary(stringCoreData:String) -> NSDictionary? //reference [1]
    {
        if let data = stringCoreData.dataUsingEncoding(NSUTF8StringEncoding)
        {
            do
            {
                
                let dictionary: NSDictionary! = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
                return dictionary
            }
            catch let error as NSError
            {
                print(error)
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func parseJSONNSDictionaryToString(dict:NSDictionary) -> NSString?
    {
        
        do
        {
            let data = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
            
            if let json = NSString(data: data, encoding: NSUTF8StringEncoding)
            {
                return json
            }
            
            return nil
        }
        catch let error as NSError
        {
            print(error)
            return nil
        }
    }

    
}


//reference [1] http://stackoverflow.com/questions/29221586/swift-how-to-convert-string-to-dictionary
