//
//  TasksTableViewController.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/4/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import UIKit
import CoreData

//protocol APIControllerProtocol
//{
//    func didReceiveAPIResults(results:NSArray)
//    
//}
protocol ItemsListControllerProtocol
{
    func didChangeItemsList(results:NSArray)
}

protocol NotesControllerProtocol
{
    func didChangeNotes(results:NSString)
}

class TasksTableViewController: UITableViewController,  ItemsListControllerProtocol,NotesControllerProtocol //,APIControllerProtocol
{
    //MARK: - Attributes
    // create context manager for coredata
    
    var delegator:sendBackTaskToServerProtocol!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var groceryListsArray: Array<GroceryList> = [] // initialize the main array list
    var groceryListsIDsArray: Array<Int> = [] // initialize the id arrays
    
    //var groceryListSelected:GroceryList!
    var groceryListSelectedIndexPath:NSIndexPath!
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //title = "ModernMeal"
        let logo = UIImage(named: "logo-hor.png")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 38))
        imageView.image = logo
        imageView.contentMode = .ScaleAspectFit
        self.navigationItem.titleView = imageView
        
        //api = APIController(delegate: self)        //create instance of API controller with self

        //tableView.registerClass(TaskTableViewCell.self, forCellReuseIdentifier: "TaskTableViewCell") //register cell


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        

    }
    
    func sincronizeCoredataAndDataBase( groceryListsIDsArrayFromServer:NSMutableArray, groceryListArrayOfDictionaries:[Int:NSDictionary])
    {
        if loadContext() // CoreData, load context of previous information if this exists in the device
        {
            //compare ids by grocery list in core data
            for aGroceryList in groceryListsArray
            {
                if groceryListsIDsArrayFromServer.containsObject(aGroceryList.id)
                {
                    //compare lasts dates updated
                    let aStringDate =  groceryListArrayOfDictionaries[aGroceryList.id]!["grocery_list"]!["updated_at"] as! String

                    if  stringToDate(aStringDate).timeIntervalSince1970 > stringToDate(aGroceryList.updated_at as String).timeIntervalSince1970
                    {
                        //replace the las grocery List with the new one updated
                        print("last update gl[\(aGroceryList.id)] was : \(aGroceryList.updated_at)")
                        aGroceryList.groceryListJSON =  api.parseJSONNSDictionaryToString(groceryListArrayOfDictionaries[aGroceryList.id]!) as? String
                        aGroceryList.setModelAtributes() //set instances of each atribute of the model GroceryList class
                        print("new update gl[\(aGroceryList.id)] was : \(aGroceryList.updated_at)")
                        print("SERVER: \(stringToDate(aStringDate)) IS THE MOST RECENT THAN: \(stringToDate(aGroceryList.updated_at as String))!!!")
                        
                    }
                    else
                    {
                        
                        
                        print("COREDATA: \(stringToDate(aStringDate)) IS THE MOST RECENT THAN: \(stringToDate(aGroceryList.updated_at as String))!!!")
                    }
                    
                    //for not repeat object
                    groceryListsIDsArrayFromServer.removeObject(aGroceryList.id)
                }
                
                
            }
        }
        
        if groceryListsIDsArrayFromServer.count != 0 // check if this is not empty
        {
            for groceryListID in groceryListsIDsArrayFromServer //add the new gls in the list
            {
                addGroceryList(groceryListArrayOfDictionaries[Int(groceryListID as! NSNumber)]!)
                //print("--- Apended: \(groceryListID)")
            }
            
        }

        //print(groceryListArrayOfDictionaries)
    }
    
   
    
    //MARK: Time helper functions
    func stringToDate(aStringDate:String) -> NSDate
    {
        let dateFormatter = NSDateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-ddTkk:mm:ssZ" /*http://userguide.icu-project.org/formatparse/datetime*/
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" //http://stackoverflow.com/questions/28791771/swift-iso-8601-date-formatting-with-ios7
        let date = dateFormatter.dateFromString(aStringDate)
        
        return date!

    }
    
    func dateToString(aDate:NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" //http://stackoverflow.com/questions/28791771/swift-iso-8601-date-formatting-with-ios7
        let date = dateFormatter.stringFromDate(aDate)
        
        return date
        
    }
    
    
    //MARK - Set

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //===================================================================================================================
    // MARK: - Table view data source and functions
    //===================================================================================================================

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        //  return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //  return the number of rows
        return groceryListsArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:TaskTableViewCell = tableView.dequeueReusableCellWithIdentifier("TaskTableViewCell", forIndexPath: indexPath) as! TaskTableViewCell

        // Configure the cell...
        
        let aGroceryList:GroceryList = groceryListsArray[indexPath.row] as GroceryList
        
        
        //print(groceryList)

        cell.textLabel?.text = aGroceryList.get_name()
        
        if aGroceryList.get_shopped()
        {
            cell.detailTextLabel?.text = "The Shopping list is completed :)"
        }
        else
        {
            cell.detailTextLabel?.text = "Missing ingredients :("
        }
    

        return cell
    }
    
    //MARK: Select Row
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //groceryListSelected = groceryListsArray[indexPath.row] as GroceryList
        
        groceryListSelectedIndexPath = indexPath
        self.performSegueWithIdentifier("ShowTabBarControllerSegue", sender: self) //call the segue to navigate at tabBarController

    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    //===================================================================================================================
    
    //MARK: - Section titles and Style
    
    //===================================================================================================================
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        
        
        return "Upcoming Grocery Lists"
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) //reference [1]
    {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        
        //Style 1
//      header.contentView.backgroundColor = ModernMealGreenColor //make the background color light blue
//      header.textLabel!.textColor = UIColor.whiteColor() //make the text white
        
        //Style 2
        header.contentView.backgroundColor = UIColor.whiteColor() //make the background color light blue
        header.textLabel!.textColor = ModernMealGreenColor//make the text white
        header.textLabel!.textAlignment = .Center
        
        // header.alpha = 0.5 //make the header transparent
    }

    //===================================================================================================================
    // MARK: - Navigation
    //===================================================================================================================

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ShowTabBarControllerSegue"
        {
            let tabBarViewController = segue.destinationViewController as! UITabBarController
           // let nav = tabBarViewController.viewControllers![0] as! UINavigationController
           // let destinationViewController = nav.topViewController as! GroceryListTableViewController
            
            //Set infroamtion in Items List Tab
            //let listTableVC = tabBarViewController.viewControllers![0] as! GroceryListTableViewController
            let listTableVC = tabBarViewController.viewControllers![0] as! GroceryListViewController
            
            let selectedGroceryList:GroceryList = groceryListsArray[groceryListSelectedIndexPath.row] as GroceryList
            
           
                //print(groceryList)
                if let grocery_list_items:Array = selectedGroceryList.grocery_list_items
                {
                    if let grocery_list:NSDictionary = selectedGroceryList.get_grocery_list()
                    {
                        if let grocery_list_Id:Array = selectedGroceryList.get_grocery_list_item_ids()
                        {
                            if let category_order:Array  = selectedGroceryList.get_category_order()
                            {
//                                if let category_order:Array = category_orderString.componentsSeparatedByString(",") //split categories by coma = array of categories
//                                {
                                    //Set all values of the next Items tableViewController
                                    listTableVC.delegator = self
                                    listTableVC.groceryList = selectedGroceryList
                                    listTableVC.grocery_list_item_ids = grocery_list_Id
                                    listTableVC.grocery_list_items = grocery_list_items
                                    listTableVC.category_order = category_order
                                    listTableVC.navigationItem.title = selectedGroceryList.get_name()
//                                }
                            }
                        }
                        
                        //Set infromation in Customer Tab
                        let customerVC = tabBarViewController.viewControllers![1] as! CustomerViewController
                        customerVC.customerName = selectedGroceryList.get_name()
                        customerVC.address = selectedGroceryList.get_name() // <=========== no defined in json, replace it after!!
                        customerVC.exclusions = selectedGroceryList.get_name() // <=========== no defined in json, replace it after!!
                        
                        //Set information in Notes Tab
                        let notesVC = tabBarViewController.viewControllers![2] as! NotesViewController
                        notesVC.delegator = self
                        
                        if let notesString: String = selectedGroceryList.notesString
                        {
                            notesVC.notes = notesString
                            
                            //Set infromation in Customer Tab Notes too
                            customerVC.notes = notesString
                        }

                    }
                    
                }
        }
    }
    
    //===================================================================================================================
    //MARK: - Protocol functions:
    //===================================================================================================================
    
    
    //MARK: for Item List
    func didChangeItemsList(results:NSArray)
    {

        //print("results:")
       // print(results)
        
        groceryListsArray[groceryListSelectedIndexPath.row].set_updated_at(dateToString(NSDate())) // set present modification date
        groceryListsArray[groceryListSelectedIndexPath.row].set_grocery_list_items(results)//set item list
        saveContext()
        groceryListsArray[groceryListSelectedIndexPath.row].setModelAtributes() //(reload)set instances of each atribute of the model GroceryList class
        
        delegator.didReceiveTaskResults(groceryListsArray[groceryListSelectedIndexPath.row])
        
        tableView.reloadData()
        
    }
    
    //MARK: for notes
    func didChangeNotes(results:NSString)
    {
        addNewNote(results)
    }
    
    

    //===================================================================================================================
    //MARK: - CoreData
    //===================================================================================================================
    
    //Create new core data GRoceryList object and save it
    func addGroceryList(aGroceryListDict:NSDictionary)
    {
        if let dictionaryString = api.parseJSONNSDictionaryToString(aGroceryListDict) as? String
        {
            // create a new core data object
            let newGroceryList = NSEntityDescription.insertNewObjectForEntityForName("GroceryList", inManagedObjectContext: managedObjectContext) as! GroceryList
            
            newGroceryList.groceryListJSON = dictionaryString
            newGroceryList.setModelAtributes() //set instances of each atribute of the model GroceryList class
            groceryListsIDsArray.append(newGroceryList.id)
            groceryListsArray.append(newGroceryList)
            saveContext()
        }
        
    }
    
    // add a new note in the grocery list
    func addNewNote(note:NSString)
    {
        groceryListsArray[groceryListSelectedIndexPath.row].notesString = note as String
        saveContext()
    }
    
    //MARK: Load context
    func loadContext() -> Bool
    {
        let fetchRequest = NSFetchRequest (entityName: "GroceryList")        //fethc the list of task from core data
        
        
        do
        {
            //conver the result from coredata in array
            if let fetchRequestResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? Array<GroceryList>
            {
                // To make equal the array coredata to array<gl>
                groceryListsArray = fetchRequestResults //<============================
               // print(groceryListsArray)
                
                for groceryLists in groceryListsArray
                {
                    let newGroceryList:GroceryList = groceryLists as GroceryList
                    
                    newGroceryList.setModelAtributes()
                    
                    //register the id in the array of ids to internal fast searchs
                    groceryListsIDsArray.append(newGroceryList.id)

                }
                
                
            
                //print(groceryListsIDsArray)
                return true //succes!There is information stored in Core data
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
