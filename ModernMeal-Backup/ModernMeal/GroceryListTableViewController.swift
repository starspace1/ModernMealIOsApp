//
//  GroceryListTableViewController.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/12/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import UIKit
import CoreMotion

class GroceryListTableViewController: UITableViewController
{
    var delegator:ItemsListControllerProtocol!
    var groceryList:GroceryList!
    var grocery_list_items: Array<NSDictionary> = []
    var grocery_list_item_ids:Array<NSNumber> = []
    var category_order: Array<String> = []
    
    var groceryListItemsDictionary = [String: Array<Item>]()
    var current_categories:Array<String> = []
    
    
    var undoHistory:NSMutableArray = []
    

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        

        
        //groceryListItems = groceryList["grocery_list_items"] as NSArray as Array
        
        createDictionaryOfItems()
        
        //tableView.rowHeight = UITableViewAutomaticDimension

        
    }
 
    
    func createDictionaryOfItems()
    {
        print("category_order")
        print(category_order)
        print("grocery_list_items")
        print(grocery_list_items)
        
        for item in grocery_list_items
        {
            //Append Item in dictionary by category
            if (groceryListItemsDictionary[item["category"] as! NSString as String] != nil)
            {
                groceryListItemsDictionary[item["category"] as! NSString as String]!.append(Item(ItemDict: item))

            }
            else
            {
                // this is nescesary to initialize the internal array inside the dictinary or will show error
                groceryListItemsDictionary[item["category"] as! NSString as String] = []
                current_categories.append(item["category"] as! NSString as String)
            }
        }
        
  
//        print(groceryListItemsDictionary.count)
    }

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
        //return the number of sections  = how many categories
        return category_order.count//current_categories.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //return the number of rows in each section
        if let aSection = groceryListItemsDictionary[category_order[section]]//groceryListItemsDictionary[current_categories[section]]!
        {
            return aSection.count// + 1
        }
        else
        {
            return 0
        }
        
        //print(aSection)
        
        
        
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
//
//       // return UITableViewAutomaticDimension
////        let groceryListItem:NSDictionary = grocery_list_items[indexPath.row]
////        UIScreen.mainScreen().bounds.width
        
        var cellHeight = 0

        let anItem:Item = groceryListItemsDictionary[category_order[indexPath.section]]![indexPath.row]
        
            if anItem.getTotalNumberOfLinesTexTLabel() >= 2 || anItem.getTotalNumberOfLinesDetailLabel() > 2
            {
                cellHeight = (anItem.getTotalNumberOfLinesTexTLabel() + anItem.getTotalNumberOfLinesDetailLabel()) * 30
            }
            else
            {
                cellHeight = (anItem.getTotalNumberOfLinesTexTLabel() + anItem.getTotalNumberOfLinesDetailLabel()) * 70
            }
    
        
        return CGFloat(cellHeight)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
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
                
                if anItem.shopped
                {
                    cell.accessoryType = .Checkmark
                }
                
            }
            
//        }
        

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let anItem:Item = groceryListItemsDictionary[category_order[indexPath.section]]![indexPath.row]
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell!.accessoryType == UITableViewCellAccessoryType.None
        {
            cell!.accessoryType = .Checkmark
            undoHistory.addObject(indexPath)
            anItem.shopped = true
        }
        else
        {
            cell!.accessoryType = .None
            undoHistory.removeObject(indexPath)
            anItem.shopped = false
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    
    //===================================================================================================================
    
    //MARK: - Section titles
    
    //===================================================================================================================
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if groceryListItemsDictionary[category_order[section]]?.isEmpty == false
        {
            return category_order[section]
        }
        
        return ""
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
            if undoHistory.count > 0
            {
                let indexPath:NSIndexPath = undoHistory.lastObject as! NSIndexPath
                let anItem:Item = groceryListItemsDictionary[category_order[indexPath.section]]![indexPath.row]
                anItem.shopped = false
                undoHistory.removeObject(indexPath)
                print("removed: \(indexPath)")
                
                tableView.reloadData()
            }
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
