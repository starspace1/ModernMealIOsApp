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
                print("data couldn't be parsed: \(error)")
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
                            print("data couln't be parsed: \(error)")
                        }
                        
                    }
            }
            authentificationTask.resume()
        }
        
    }
    
    func update(groeryList:GroceryList)
    {
        
        if signedIn
        {
            let fullUrl = "\(baseUrl)/api/v1/grocery_lists/\(groeryList.id)?auth_token="+token
            let request = NSMutableURLRequest(URL: NSURL(string: fullUrl)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPMethod = "POST"
            let updateData = groeryList.getGroceryListJSONAsNSDictionary()
            
            do
            {
                let postData = try NSJSONSerialization.dataWithJSONObject(updateData!, options: NSJSONWritingOptions.PrettyPrinted)
                request.HTTPBody = postData
                
            }
            catch let error as NSError
            {
                print("data couldn't be parsed: \(error)")
            }
            
            let session = NSURLSession.sharedSession()
            let updateDataTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) // here I send the json file modified
                {
                    data, response, error -> Void in
                    if error == nil
                    {
                        print("data was sent: \(response)")
                        
//                        do
//                        {
//                            let postData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
////                            if let postDataDict:NSDictionary = (postData as! NSDictionary)
////                            {
////                                //self.token = postDataDict["token"] as! NSString as String
////                                
//                                print("data was sent: \(postData)")
////
////                               // self.delegator.didReceiveHTTPResults(self.token)
////                            }
//                        }
//                        catch let error as NSError
//                        {
//                            print("data couln't be sent: \(error)")
//                        }
                        
                        
                        
                    }
            }
            updateDataTask.resume()
        }
        
    }
}