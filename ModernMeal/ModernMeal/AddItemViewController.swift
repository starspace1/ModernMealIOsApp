//
//  AddItemViewController.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/29/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import UIKit



class AddItemViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, HTTPControllerProtocol
{
    @IBOutlet weak var item_nameTextLabel: UILabel!
    @IBOutlet weak var recipe_nameTextLabel: UILabel!
    
    @IBOutlet weak var item_nameTextField: UITextField!
    @IBOutlet weak var recipe_nameTextField: UITextField!
    @IBOutlet weak var textTextField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    
//    var httpController: HTTPController!
    
    var delegator: AddItemProtocol!
    
    var newItem:Item!
    
    var grocery_list_id: Int!
    var category_order: Array<String> = []
    var created_at:String = ""
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        httpController = HTTPController(delegate: self)
        httpController.delegator = self

        let saveItemButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveItemButtonAction:")
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = saveItemButton//self.editButtonItem()]
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        recipe_nameTextField.enabled = false
        recipe_nameTextField.alpha = 0.5
        recipe_nameTextLabel.alpha = 0.5
        item_nameTextField.enabled = false
        item_nameTextField.alpha = 0.5
        item_nameTextLabel.alpha = 0.5

        
        //check if is an update or is adding a new item
        if newItem != nil
        {
            title = "Edit "+newItem.item_name
            self.navigationItem.rightBarButtonItem?.enabled = true
            
            item_nameTextField.text = newItem.item_name
            recipe_nameTextField.text = newItem.recipe_name
            textTextField.text = newItem.text
            let index = category_order.indexOf(newItem.category)
            categoryPicker.selectRow(index!, inComponent: 0, animated: true)
            
        }
        else
        {
            title = "Add Item"
            
            item_nameTextField.text = ""
            item_nameTextField.alpha = 0.0
            item_nameTextLabel.alpha = 0.0

            recipe_nameTextField.text = "Manually Entered"
            textTextField.text = ""
            let index = category_order.indexOf("Other & Uncategorized")
            categoryPicker.selectRow(index!, inComponent: 0, animated: true)
            categoryPicker.userInteractionEnabled = false
            categoryPicker.alpha = 0.5
        }
        
        textTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - SendBack Info
    override func viewWillDisappear(animated: Bool)
    {
    }
    
   
    
    //===================================================================================================================
    //MARK: - Text Field functions
    //===================================================================================================================
    
    @IBAction func item_nameActionEditingDidEnd(sender: UITextField)
    {
        if textTextField.text != ""//item_nameTextField.text != "" && textTextField.text != ""
        {
           
            self.navigationItem.rightBarButtonItem?.enabled = true
            
        }
        else
        {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    @IBAction func item_nameActionEditiongChanged(sender: UITextField)
    {
        if textTextField.text != ""//item_nameTextField.text != "" && textTextField.text != ""
        {
            
            self.navigationItem.rightBarButtonItem?.enabled = true
            
        }
        else
        {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    //===================================================================================================================
    //MARK: - Picker Functions
    //===================================================================================================================
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return category_order.count
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView //reference [1]
    {
        let pickerLabel = UILabel()
        pickerLabel.textColor = ModernMealStrongGreyColor
        pickerLabel.numberOfLines = 0
        pickerLabel.text = category_order[row] //"ModernMeal"
//                 pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 23)
        pickerLabel.font = UIFont(name: "Raleway", size: 20) // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
    

    
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
//    {
//        
//        return category_order[row]
//    }
    
    //MARK: - Helpers
    func dateToString(aDate:NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" //http://stackoverflow.com/questions/28791771/swift-iso-8601-date-formatting-with-ios7
        let date = dateFormatter.stringFromDate(aDate)
        
        return date
        
    }
    //===================================================================================================================
    //MARK: - Action Handlers 
    //===================================================================================================================
    
    func saveItemButtonAction(sender:UIBarButtonItem)
    {
        if textTextField.text != ""// || item_nameTextField.text != nil
        {
            var isNew = false
            
            
            
            //determinate the current date of updating
            let now = dateToString(NSDate())
            //determinate the final category
            let category:String = category_order[categoryPicker.selectedRowInComponent(0)]
            
            //if the item is new
            if created_at == ""
            {
                created_at = now
            }
            
            
            //check if is an new Item or edition
            if let id = newItem?.id
            {

                print("updating  item")
                newItem = Item(ItemDict: NSDictionary(dictionary:
                    [
                        "id": newItem.id,
                        "recipe_id": newItem.recipe_id,
                        "grocery_list_id": grocery_list_id,
                        "category": category,
                        "text": textTextField.text! ,
                        "recipe_name": newItem.recipe_name,//recipe_nameTextField.text!,
                        "shopped": false,
                        "item_name": newItem.item_name,//item_nameTextField.text!,
                        "created_at": created_at,
                        "updated_at": now
                    ]
                    ))
                
                newItem.method = "PUT"
                
                if httpController.update(newItem)
                {}else{}
                
                
                
            }
            else
            {
                 print("adding new item")
                
                isNew = true
                
                newItem = Item(ItemDict: NSDictionary(dictionary:
                    [
                        "grocery_list_id": grocery_list_id,
                        "category": category,
                        "text": textTextField.text! ,
                        "recipe_name": recipe_nameTextField.text!,
                        "shopped": false,
                        "item_name": item_nameTextField.text!,
                        "created_at": created_at,
                        "updated_at": now
                    ]
                    ))
                
                newItem.method = "POST"
                
                if httpController.create(newItem)
                {}else{}

            }
        

            //delegator.itemWasCreated(newItem,isNew: isNew)
            
            
            
        }

    }
    
    func updateItem(item:Item)
    {
        print("ID: \(item.id)")
        delegator.itemWasCreated(item,isNew: false)
    }
    
    func createItem(item:Item)
    {
        print("ID: \(item.id)")
        delegator.itemWasCreated(item,isNew: true)
    }
    func didReceiveHTTPResults(token:String)
    {
        dispatch_async(dispatch_get_main_queue(),
            {
        })
    }
    
    func delteItem(item:Item)
    {
    }
    
    func msgResponse(title:String,message:String)
    {
        dispatch_async(dispatch_get_main_queue(),
        {
                let popUpAlertController = UIAlertController(title: title , message: message, preferredStyle: UIAlertControllerStyle.Alert)
                popUpAlertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(popUpAlertController, animated: true, completion: nil)
        })
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
// reference [1] http://stackoverflow.com/questions/27455345/uipickerview-wont-allow-changing-font-name-and-size-via-delegates-attributedt