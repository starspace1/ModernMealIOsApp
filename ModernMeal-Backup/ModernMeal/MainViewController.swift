//
//  ViewController.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/4/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import UIKit

protocol APIControllerProtocol
{
    func didReceiveAPIResults(results:NSMutableArray)
    func didReceiveListOfListsFromAPIResults(results:[Int:NSDictionary])
    
}
protocol HTTPControllerProtocol
{
    func didReceiveHTTPResults(token:String)
    
}

protocol sendBackTaskToServerProtocol
{
    func didReceiveTaskResults(groceryList:GroceryList)
}

var api: APIController!

class MainViewController: UIViewController, UITextFieldDelegate, NSURLSessionDelegate, HTTPControllerProtocol, APIControllerProtocol, sendBackTaskToServerProtocol
{
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var httpController: HTTPController!
    var arrayResults = [Int:NSDictionary]()
    var arrayIDs: NSMutableArray!
    //var api: APIController!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        httpController = HTTPController(delegate:self)
        
        //create instance of API controller with self
        api = APIController(delegate: self)
        
       usernameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInTapped(sender: UIButton)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        httpController.singIn(usernameTextField.text!, password: passwordTextField.text!)
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }
    
    //MARK: Protocol functions
    
    func didReceiveHTTPResults(token:String)
    {
        dispatch_async(dispatch_get_main_queue(),
        {
                api.getListOfGroceryListsFromAPIModernMeal(token)
                
        })
    }
    
    func didReceiveAPIResults(results:NSMutableArray)
    {
        dispatch_async(dispatch_get_main_queue(),
        {
                print(results)
            self.arrayIDs = results
                api.getGroceryListFromAPIModernMeal(results)


        })
    }
    
    func didReceiveListOfListsFromAPIResults(results:[Int:NSDictionary])
    {
        dispatch_async(dispatch_get_main_queue(),
        {
            print("didReceiveListOfListsFromAPIResults")
            //print(results)
            self.arrayResults = results
            print("----------end")
          
            //call the segue to navigate at tabBarController
            self.performSegueWithIdentifier("PresentTaskTableViewControllerSegue", sender: self)
        })
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "PresentTaskTableViewControllerSegue"
        {

            
            let navigationController = segue.destinationViewController as! UINavigationController

            let taskTableVC:TasksTableViewController = navigationController.viewControllers[0] as! TasksTableViewController
            taskTableVC.delegator = self
            taskTableVC.sincronizeCoredataAndDataBase(self.arrayIDs,groceryListArrayOfDictionaries: self.arrayResults)
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        }
    }
    
    func didReceiveTaskResults(groceryList:GroceryList)
    {
        dispatch_async(dispatch_get_main_queue(),
            {
                self.httpController.update(groceryList)
        })
    }

        
    

}

