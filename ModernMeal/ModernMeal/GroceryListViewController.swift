//
//  GroceryListViewController.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/21/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import UIKit
import CoreMotion

protocol AddItemProtocol
{
    func itemWasCreated(item:Item,isNew:Bool)
}

class GroceryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddItemProtocol, HTTPControllerProtocol
{
    
    @IBOutlet weak var tableView: UITableView!
    
//    var httpController:HTTPController!
    
    var delegator:ItemsListControllerProtocol!
    var groceryList:GroceryList!
    var grocery_list_items: Array<NSDictionary> = []
    var grocery_list_item_ids:Array<NSNumber> = []
    var category_order: Array<String> = []
    
    var groceryListItemsDictionary = [String: Array<Item>]()
    var current_categories:Array<String> = []
    
    
    var undoShoppedHistory:NSMutableArray = []
    
    var currentCellIndexPath:NSIndexPath!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//         httpController = HTTPController(delegate: self)
        
        httpController.delegator = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        //groceryListItems = groceryList["grocery_list_items"] as NSArray as Array
        
        createDictionaryOfItems()
        
        //tableView.rowHeight = UITableViewAutomaticDimension
        
        
    }
    
    //http://stackoverflow.com/questions/33707512/how-to-set-title-of-navigation-bar-in-swift
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        
        
        self.tabBarController?.navigationItem.title = groceryList.get_name()
                
        let editItemButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "editItemButtonAction:")

        let addItemButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addItemButtonAction:")
 
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.tabBarController?.navigationItem.rightBarButtonItems = [addItemButton, editItemButton]//self.editButtonItem()]
        
        self.tabBarController?.navigationItem.rightBarButtonItems?.last?.enabled = false
       
    }
    
    //MARK: - Dictionary of items by category
    func createDictionaryOfItems()
    {

        
        for category in category_order
        {
            // this is nescesary to initialize the internal array inside the dictinary or will show error
            groceryListItemsDictionary[category] = []
        }
        
        for item in grocery_list_items
        {
            //Append Item in dictionary by category
            if (groceryListItemsDictionary[item["category"] as! NSString as String] != nil)
            {
                groceryListItemsDictionary[item["category"] as! NSString as String]!.append(Item(ItemDict: item))

            }
            
        }

        //        print(groceryListItemsDictionary.count)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Send Back the updated Item list
    override func viewDidDisappear(animated: Bool)
    {
        // This fetching is nescesary for avoid any mutation in the array order
//                if undoHistory.count > 0
//                {
//                    var undoIDHistoryDict = [Int: NSDictionary]()
        
//                    for item in undoShoppedHistory
//                    {
//                        let indexPath:NSIndexPath = item as! NSIndexPath
//                        
//                        if let anItem:Item = groceryListItemsDictionary[category_order[indexPath.section]]![indexPath.row]
//                        {
//                            undoIDHistoryDict[anItem.id] = anItem.getDictionary()
//                        }
//        
//                    }
//        
//                    var grocery_list_items_copy: Array<NSDictionary> = []
//        
//                    for groceryItem in grocery_list_items
//                    {
//                        
//        
//                        if let aDictionary: NSDictionary = undoIDHistoryDict[Int(groceryItem["id"] as! NSNumber)]
//                        {
//                            grocery_list_items_copy.append(aDictionary)
//                        }
//                        else
//                        {
//                            grocery_list_items_copy.append(groceryItem)
//                        }
//        
//        
//                    }
        
        var groceryListItemsByID = [Int: NSDictionary]()
        var new_grocery_list_item_ids: Array<Int> = []
        var new_items: Array<NSDictionary> = []
        
        
        for aCategory in category_order
        {
            if groceryListItemsDictionary[aCategory]?.count > 0
            {
                for anItem in groceryListItemsDictionary[aCategory]!
                {
                    if let id = anItem.id
                    {
                        groceryListItemsByID[id] = anItem.getDictionary()
                        new_grocery_list_item_ids.append(id)
                    }
                    else
                    {
                        new_items.append(anItem.getDictionary())
                    }
                }
            }
        }
        
        new_grocery_list_item_ids = new_grocery_list_item_ids.sort()
        
        
        var grocery_list_items_copy: Array<NSDictionary> = []

        
        //creating a new grocery list sorted to send back
        for itemID in new_grocery_list_item_ids
        {
            
            grocery_list_items_copy.append(groceryListItemsByID[itemID]!)
            
        }
        for newItem in new_items
        {
            grocery_list_items_copy.append(newItem)
        }

        
                    delegator.didChangeItemsList(grocery_list_items_copy)
//                }
        
    }
    //===================================================================================================================
    
    // MARK: - Table view data source and functions
    
    //===================================================================================================================
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        //return the number of sections  = how many categories
        return category_order.count//current_categories.count
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //return the number of rows in each section
        if groceryListItemsDictionary[category_order[section]]?.count > 0//groceryListItemsDictionary[current_categories[section]]!
        {
            return groceryListItemsDictionary[category_order[section]]!.count// + 1
        }
        else
        {
            return 0
        }
        
        //print(aSection)
 
        
    }
    
//    
//     func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
//    {
//        //
//        //       // return UITableViewAutomaticDimension
//        ////        let groceryListItem:NSDictionary = grocery_list_items[indexPath.row]
//        ////        UIScreen.mainScreen().bounds.width
//        
//        var cellHeight = 0
//        
//        let anItem:Item = groceryListItemsDictionary[category_order[indexPath.section]]![indexPath.row]
//        
//        if anItem.getTotalNumberOfLinesTexTLabel() >= 2 || anItem.getTotalNumberOfLinesDetailLabel() > 2
//        {
//            cellHeight = (anItem.getTotalNumberOfLinesTexTLabel() + anItem.getTotalNumberOfLinesDetailLabel()) * 30
//        }
//        else
//        {
//            cellHeight = (anItem.getTotalNumberOfLinesTexTLabel() + anItem.getTotalNumberOfLinesDetailLabel()) * 70
//        }
//        
//        
//        return CGFloat(cellHeight)
//    }
    
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemTableViewCell", forIndexPath: indexPath) as! ItemTableViewCell
        
        // Configure the cell...
        //        if indexPath.row < groceryListItemsDictionary[current_categories[indexPath.section]]!.count
        //        {
        if let anItem:Item = groceryListItemsDictionary[category_order[indexPath.section]]![indexPath.row]
        {
            cell.textLabel?.text = anItem.text
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = anItem.recipe_name
            cell.detailTextLabel?.numberOfLines = 0
            cell.accessoryType = .None
            cell.backgroundColor = UIColor.whiteColor()
            cell.textLabel?.backgroundColor = UIColor.whiteColor()
            cell.detailTextLabel?.backgroundColor = UIColor.whiteColor()
            
            if anItem.shopped
            {
                cell.accessoryType = .Checkmark
                cell.backgroundColor = ModernMealSoftGreenColor
                
                cell.textLabel?.backgroundColor = ModernMealSoftGreenColor
                cell.detailTextLabel?.backgroundColor = ModernMealSoftGreenColor

            }
            
        }
        
        //        }
        
        return cell
    }
    
    //MARK: Select cell item
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let anItem:Item = groceryListItemsDictionary[category_order[indexPath.section]]![indexPath.row]
        {
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.backgroundColor = UIColor.whiteColor()
            
            if cell!.accessoryType == UITableViewCellAccessoryType.None
            {
                cell!.accessoryType = .Checkmark
                cell?.backgroundColor = ModernMealSoftGreenColor
                cell!.textLabel?.backgroundColor = ModernMealSoftGreenColor
                cell!.detailTextLabel?.backgroundColor = ModernMealSoftGreenColor
//                undoHistory.addObject(indexPath)
                anItem.shopped = true
            }
//            else
//            {
//                cell!.accessoryType = .None
////                undoHistory.removeObject(indexPath)
//                anItem.shopped = false
//            }
            
            if !undoShoppedHistory.containsObject(indexPath)
            {
                undoShoppedHistory.addObject(indexPath)
            }
            
            httpController.delegator = self
            
            httpController.update(anItem)
            
            currentCellIndexPath = indexPath
            
            self.tabBarController?.navigationItem.rightBarButtonItems?.last?.enabled = true
            
            

            //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }
    
    //MARK: Editon mode
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            // Delete the row from the data source
            if let anItem:Item = groceryListItemsDictionary[category_order[indexPath.section]]![indexPath.row]
            {
                anItem.method = "DELETE"
                
                //if item was deleted in the server, delete it in the app
               
                    if httpController.delete(anItem)
                    {}
                    else{}
                        
                        self.undoShoppedHistory.removeObject(indexPath)
                        self.tabBarController?.navigationItem.rightBarButtonItems?.last?.enabled = false
                        
                        //if the element exist, erase it
                        self.groceryListItemsDictionary[self.category_order[indexPath.section]]?.removeAtIndex(indexPath.row)
                        //delete table cell
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    
                
                
            }
            
            
        }
        //        else if editingStyle == .Insert
        //        {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //        }
        tableView.reloadData()
    }
    
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
    
     func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if groceryListItemsDictionary[category_order[section]]?.isEmpty == false
        {
            return category_order[section]
        }
    
        return ""
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) //reference [1]
    {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        
        //Style 1
        //        header.contentView.backgroundColor = ModernMealGreenColor //make the background color light blue
        //        header.textLabel!.textColor = UIColor.whiteColor() //make the text white
        
        //Style 2
        //        header.contentView.backgroundColor = ModernMealGreenColor //make the background color light blue
        //UILabel.appearance().font = UIFont(name: "Raleway", size: 15)
        header.textLabel?.font = UIFont(name: "Raleway", size: 16)

        header.textLabel!.textColor = ModernMealGreenColor//make the text white
        header.textLabel!.textAlignment = .Center
        
        // header.alpha = 0.5 //make the header transparent
    }
    
   
    
   
    //===================================================================================================================
    //MARK: - Motion Shake
    //===================================================================================================================
    override func canBecomeFirstResponder() -> Bool
    {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?)
    {
        if motion == .MotionShake
        {
            if undoShoppedHistory.count > 0
            {
                let indexPath:NSIndexPath = undoShoppedHistory.lastObject as! NSIndexPath
                let anItem:Item = groceryListItemsDictionary[category_order[indexPath.section]]![indexPath.row]
                anItem.shopped = !anItem.shopped //change the state for the last one
                self.tabBarController?.navigationItem.rightBarButtonItems?.last?.enabled = false
                httpController.delegator = self
                
                httpController.update(anItem)

                undoShoppedHistory.removeObject(indexPath)
               // print("removed: \(indexPath)")
                
                tableView.reloadData()
            }
        }
    }
    

    
    
    
    //===================================================================================================================
    //MARK: - Action Handlers
    //===================================================================================================================
    
    //MARK: Add new item
    func addItemButtonAction(sender:UIBarButtonItem)
    {
        
        print("addItemButtonAction typed")
        
        let addItemVC = storyboard?.instantiateViewControllerWithIdentifier("AddItemViewController") as! AddItemViewController
        addItemVC.delegator = self
        addItemVC.grocery_list_id = groceryList.id
        addItemVC.category_order = category_order
        navigationController?.pushViewController(addItemVC, animated: true)
        
        if currentCellIndexPath != nil
        {
            tableView.deselectRowAtIndexPath(currentCellIndexPath, animated: true)
        }
        
    }
    
    //MARK: Edit item attributes
    func editItemButtonAction(sender:UIBarButtonItem)
    {
        if currentCellIndexPath != nil
        {
            let addItemVC = storyboard?.instantiateViewControllerWithIdentifier("AddItemViewController") as! AddItemViewController
            addItemVC.delegator = self
            //only difference: send the item to modify
            addItemVC.newItem = groceryListItemsDictionary[category_order[currentCellIndexPath.section]]![currentCellIndexPath.row]
            addItemVC.grocery_list_id = groceryList.id
            addItemVC.category_order = category_order
            navigationController?.pushViewController(addItemVC, animated: true)
            tableView.deselectRowAtIndexPath(currentCellIndexPath, animated: true)
        }
    }
    //===================================================================================================================
    //MARK: - Protocol Functions
    //===================================================================================================================
    
    func itemWasCreated(item:Item,isNew:Bool)
    {
        print(">> itemWasCreated:")
        print(item.text)
        
        if isNew
        {
            //add the new item at the right category
            groceryListItemsDictionary[item.category]!.append(item)
            
        }
        else
        {
            //ask if the category of the new item is equal/same to the old one(modified)
            if item.category == groceryListItemsDictionary[category_order[currentCellIndexPath.section]]![currentCellIndexPath.row].category
            {
                //replace old item with new item
                groceryListItemsDictionary[category_order[currentCellIndexPath.section]]![currentCellIndexPath.row] = item
            }
            else
            {
                //if exists in the history shoped erase it
                if undoShoppedHistory.containsObject(currentCellIndexPath)
                {
                    undoShoppedHistory.removeObject(currentCellIndexPath)

                }
                //remove the old item

                groceryListItemsDictionary[category_order[currentCellIndexPath.section]]!.removeAtIndex(currentCellIndexPath.row)
                //delete table cell
                //tableView.deleteRowsAtIndexPaths([currentCellIndexPath], withRowAnimation: .Fade)
                
                //add the modified item at the right category
                groceryListItemsDictionary[item.category]!.append(item)
            }
        }
        
        
        tableView.reloadData()
    }
    
    func didReceiveHTTPResults(token:String)
    {
        dispatch_async(dispatch_get_main_queue(),
            {
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
    
    func msgResponse(title:String,message:String)
    {
//        dispatch_async(dispatch_get_main_queue(),
//            {
//                let popUpAlertController = UIAlertController(title: title , message: message, preferredStyle: UIAlertControllerStyle.Alert)
//                popUpAlertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
//                self.presentViewController(popUpAlertController, animated: true, completion: nil)
//        })
    }


    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    

}
//reference[1]:http://www.elicere.com/mobile/swift-blog-2-uitableview-section-header-color/