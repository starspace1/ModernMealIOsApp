//
//  NotesViewController.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/12/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, UITextViewDelegate
{

    @IBOutlet weak var addNoteTextField: UITextView!
    
    var delegator: NotesControllerProtocol!
    var notes:String = ""//"Type here your note..."
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        
        addNoteTextField.text = notes
        addNoteTextField.becomeFirstResponder()
    }
    
    //nescesary to clean the array in the right navigation bar
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.tabBarController?.navigationItem.rightBarButtonItems = []//self.editButtonItem()]
        
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        if addNoteTextField.text != ""
        {
            delegator.didChangeNotes(addNoteTextField.text)
        }
    }
    
//    func textViewDidBeginEditing(textView: UITextView)
//    {
//        if textView.text == "Type here your note..."
//        {
//            
//        }
//    }
    
    func textViewDidEndEditing(textView: UITextView)
    {
        delegator.didChangeNotes(textView.text)
        addNoteTextField.resignFirstResponder()
        NSNotificationCenter.defaultCenter()
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
