//
//  ViewController.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/4/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import UIKit
import CoreData


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
var httpController: HTTPController!

class MainViewController: UIViewController, UITextFieldDelegate, NSURLSessionDelegate, HTTPControllerProtocol, APIControllerProtocol, sendBackTaskToServerProtocol
{
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    
    var arrayResults = [Int:NSDictionary]()
    var arrayIDs: NSMutableArray!
    
//    var token: String = ""
    var username: String = ""
    //var api: APIController!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        httpController = HTTPController(delegate:self)
        
        //create instance of API controller with self
        api = APIController(delegate: self)
        
        if loadContext()
        {
           
        }
        else
        {
            usernameTextField.becomeFirstResponder()
        }
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        
        
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
        let newUser = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: managedObjectContext) as! User
        print("token to save: \(token)")
        newUser.token = token
        newUser.name = username
        saveContext()
        
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
//                httpController.update(groceryList)
        })
    }
    
    //MARK: - CoreData:
    //MARK: Load context
    func loadContext() -> Bool
    {
        let fetchRequest = NSFetchRequest(entityName: "User")        //fethc the list of task from core data
        
        
        do
        {
            //conver the result from coredata in array
            if let fetchRequestResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? Array<User>
            {
                // To make equal the array coredata to array<gl>
              
                var token = ""
                
                for user in fetchRequestResults
                {
                    let newUser:User = user as User
                    
                    token = newUser.token!
                    username = newUser.name!
                    
                }
                
                
                
                print("token to load: \(token)")
                
                if token != ""
                {
                    usernameTextField.enabled = false
                    passwordTextField.enabled = false
                    signInButton.enabled = false
                    
                    httpController.token = token
                    
//                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    api.getListOfGroceryListsFromAPIModernMeal(token)
                    return true //succes!There is information stored in Core data

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

