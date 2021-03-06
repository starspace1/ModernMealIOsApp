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
    func msgResponse(title:String,message:String)
    
}
protocol HTTPControllerProtocol
{
    func didReceiveHTTPResults(token:String)
    func createItem(item:Item)
    func updateItem(item:Item)
    func delteItem(item:Item)
    func msgResponse(title:String,message:String)
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
    
    var popUpAlertController:UIAlertController!
    
    var arrayResults = [Int:NSDictionary]()
    var arrayIDs: NSMutableArray!
    
    var username: String = ""
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        httpController = HTTPController(delegate:self)
        
        //create instance of API controller with self
        api = APIController(delegate: self)
        
        
        usernameTextField.enabled = false
        passwordTextField.enabled = false
        signInButton.enabled = false
        
        
        if !loadContext()
        {
            usernameTextField.enabled = true
            passwordTextField.enabled = true
            signInButton.enabled = true
            usernameTextField.becomeFirstResponder()
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),
            {
                self.popUpAlertController = UIAlertController(title: "Synchronizing..." , message: "Synchronizing your device information with the Modernmeal service.", preferredStyle: UIAlertControllerStyle.Alert)
                print("CALL historyStoredTSynchronization")
                httpController.historyStoredTSynchronization()
                
                self.presentViewController(self.popUpAlertController, animated: true, completion: nil)
            })
        }
     
        
    }


    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITextField functions
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField.text != ""
        {
            if usernameTextField.isFirstResponder()
            {
                usernameTextField.resignFirstResponder()
                passwordTextField.becomeFirstResponder()
                return true
            }
            if passwordTextField.isFirstResponder()
            {
                passwordTextField.resignFirstResponder()

                authorizationRequest()
                return true
            }
        }
        return false
    }
    //===================================================================================================================

    //MARK: - Action handlers
    
    //===================================================================================================================

    @IBAction func signInTapped(sender: UIButton)
    {
        // this is for avoid the nil error 
        authorizationRequest()
        
    }
    //===================================================================================================================

    // MARK - Helper signIn
    
    //===================================================================================================================

    func authorizationRequest()
    {
        dispatch_async(dispatch_get_main_queue(),
            {
                self.popUpAlertController = UIAlertController(title: "Synchronizing..." , message: "Synchronizing your device information with the Modernmeal service.", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(self.popUpAlertController, animated: true, completion: nil)
        })
        
        if usernameTextField.text != "" && passwordTextField.text != ""// && textTextField.text != ""
        {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            httpController.singIn(usernameTextField.text!, password: passwordTextField.text!)
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),
            {
                self.popUpAlertController.dismissViewControllerAnimated(true, completion:
                    
                {
                        
                    let popUpAlertController = UIAlertController(title: "Please" , message: "The fields are empty, type the correct username and password.", preferredStyle: UIAlertControllerStyle.Alert)
                    popUpAlertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(popUpAlertController, animated: true, completion: nil)
                })
            })
        }
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    //===================================================================================================================

    //MARK: Protocol functions
    
    //===================================================================================================================

    func didReceiveHTTPResults(token:String)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let newUser = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: managedObjectContext) as! User
        print("token to save: \(token)")
        newUser.token = token
        newUser.name = username
        saveContext()
        
        
        print("CALL historyStoredTSynchronization")
        
        httpController.historyStoredTSynchronization()
        
//        dispatch_async(dispatch_get_main_queue(),
//        {
//                api.getListOfGroceryListsFromAPIModernMeal(token)
//                
//        })
    }
    
    func didReceiveAPIResults(results:NSMutableArray)
    {
        dispatch_async(dispatch_get_main_queue(),
        {
                print(results)
            self.arrayIDs = results
            
            if self.arrayIDs.count > 0
            {
                
                api.getGroceryListFromAPIModernMeal(results)
            }
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
            self.popUpAlertController.dismissViewControllerAnimated(true, completion:
            {
                let navigationController = segue.destinationViewController as! UINavigationController

                let taskTableVC:TasksTableViewController = navigationController.viewControllers[0] as! TasksTableViewController
                taskTableVC.delegator = self
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                
                taskTableVC.synchronizeCoredataAndDataBase(self.arrayIDs,groceryListArrayOfDictionaries: self.arrayResults)
                
            })

        }
    }
    
    func msgResponse(title:String,message:String)
    {
        dispatch_async(dispatch_get_main_queue(),
        {
            self.popUpAlertController.dismissViewControllerAnimated(true, completion:
            
            {
                    self.popUpAlertController = UIAlertController(title: title , message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
                    {
                            UIAlertAction in
                            NSLog("OK Pressed")
                        if title != "Connection error!" && title != "Sorry!"///be careful with those messages! it have to be same from the the httpcontroller validation
                        {
                            self.performSegueWithIdentifier("PresentTaskTableViewControllerSegue", sender: self)
                        }
                        
                    }
                    self.popUpAlertController.addAction(okAction)
                
                    self.presentViewController(self.popUpAlertController, animated: true, completion: nil)
            })

        })
    }
    
    
    
    func didReceiveTaskResults(groceryList:GroceryList)
    {
        dispatch_async(dispatch_get_main_queue(),
            {
                //                httpController.update(groceryList)
        })
    }
    
    func updateItem(item:Item)
    {
        print("ID: \(item.id)")
    }
    
    func createItem(item:Item)
    {
        print("ID: \(item.id)")
    }
    
    func delteItem(item:Item)
    {
    }
    //===================================================================================================================

    //MARK: - CoreData:
    
    //===================================================================================================================

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
                    httpController.setToken(token)
                    httpController.signedIn = true
                    
//                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    api.getListOfGroceryListsFromAPIModernMeal(token)
                    return true //succes!There is information stored in Core data

                }
                else
                {
                    return false
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

