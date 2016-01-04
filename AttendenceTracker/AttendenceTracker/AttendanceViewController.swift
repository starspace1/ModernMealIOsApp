//
//  ViewController.swift
//  AttendenceTracker
//
//  Created by Pedro Trujillo on 12/4/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import UIKit

class AttendanceViewController: UIViewController, NSURLSessionDelegate, ESTBeaconManagerDelegate
{
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var gitHubUserName: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var beaconInfoLabel: UILabel!
    
    
    let beaconManager = ESTBeaconManager()
    let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 41906, minor: 7514, identifier: "Gemini classroom")
    let baseUrl = "http://tiybeacon.herokuapp.com"
    var session:NSURLSession
    var token: Int?
    var signedIn = false
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        beaconManager.delegate = self
        baconManager.requestWhenInUseAuthorization()
        greetingLabel.text = ""
        beaconInfoLabel.text = ""
    }
    
    func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion)
    {
        if beacons.count > 0
        {
            let nearestBeacon = beacons.first! as CLBeacon
            let distance: String
            
            switch nearestBeacon.proximity
            {
            case .Imediate:
                destance = "immediate (<1m)"
            case .Near:
                destance = "near (<3m)"
            case .Far:
                destance = "far (>3m)"
            case .Unknown:
                destance = "very week signal"
                
            }
            
            beaconInfoLabel.text = "Beacon distance: "+distance
            
            if nearestBeacon.proximity == CLProximity.Immediate && !signedIn
            {
                let request = NSMutableURLRequest(URL: NSURL(string: baseUrl+/attendances)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
                
            }
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerUser(sender: UIButton)
    {
        nameTextField.resignFirstResponder()
        gitHubUserName.resignFirstResponder()
        
        nameTextField.enabled = false
        gitHubUserName.enabled = false
        registerButton.enabled = false
        registerButton.enabled = true
        
        if token == nil
        {
            let fullUrl = "\(baseUrl)/users"
            let request = NSMutableURLRequest(URL: NSURL(string: fullUrl)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPMethod = "POST"
            let requestData = ["name": nameTextField.text!, "github":gitHubUserName.text!] // here I modify the json dict in whit the new information
            
            do
            {
                let postData = try NSJSONSerialization.dataWithJSONObject(requestData, options: NSJSONWritingOptions.PrettyPrinted) // here is serialazed the dictionary to json before to send
                request.HTTPBody = postData // here is packed like a http request
                
            }
            catch let error as NSError
            {
                print("data couldn't be parsed: \(error)")
            }
            
            let postDataTask = session.dataTaskWithRequest(request) // here I send the json file modified
            {
                data, response, error -> Void in
                if error == nil
                {
                    do
                    {
                        let postData = try NSJSONSerialization.JSONObjectWithData(data!, options: AllowFragments)
                        self.token = postData["user_id"] as? Int
                    }
                    catch let error as NSError
                    {
                        print("data couln't be parsed: \(error)")
                    }
                    
                    self.beaconManager.startRanginBeaconsInRegion(self.beaconRegion)
                }
            }
            
            postDataTask.resume()
            
        }
        
        else
        {
            beaconManager.startRangingBeaconsInRegion(beaconRegion)
        }
        
    }
    
    @IBAction func resetBeaconRanging(sender:UIButton)
    {}


}

