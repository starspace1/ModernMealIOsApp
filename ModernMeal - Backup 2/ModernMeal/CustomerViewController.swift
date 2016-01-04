//
//  CustomerViewController.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/12/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import UIKit

class CustomerViewController: UIViewController
{
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var exclusionsTextView: UITextView!
    @IBOutlet weak var notesTextView: UITextView!
    
    var customerName:String!
    var address:String!
    var exclusions:String!
    var notes:String = "There are not notes..."

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        customerNameLabel.text = customerName
        addressLabel.text = address
        exclusionsTextView.text = exclusions
        notesTextView.text = notes
        
        

        // Do any additional setup after loading the view.
        
        //change title button and view
    }
    
    //nescesary to clean the array in the right navigation bar 
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.tabBarController?.navigationItem.rightBarButtonItems = []//self.editButtonItem()]
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
