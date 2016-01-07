//
//  AppDelegate.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/4/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//

import UIKit
import CoreData

//MARK: - ModernMeal style colors
var ModernMealDarkGreenColor:UIColor = UIColor(red: 74/255, green: 107/255, blue: 22/255, alpha: 1.0)//#4A6B16
var ModernMealGreenColor: UIColor = UIColor(red: 126/255, green: 162/255, blue: 63/255, alpha: 1.0)//#7ba23f
var ModernMealSoftGreenColor: UIColor = UIColor(red: 144/255, green: 186/255, blue: 80/255, alpha: 1.0)//#90ba50

var ModernMealStrongGreyColor: UIColor = UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 1.0)//#444444
var ModernMealGreyColor: UIColor = UIColor(red: 154/255, green: 154/255, blue: 154/255, alpha: 1.0)//#9a9a9a
var ModernMealSoftGreyColor: UIColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)//#F2F2F2

var ModernMealOrangeColor: UIColor =  UIColor(red: 254/255, green: 117/255, blue: 0/255, alpha: 1.0) /* #fe7500 */


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Override point for customization after application launch.
        
//        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        // ...
        
//MARK: - App general style <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        //general
        self.window!.tintColor = ModernMealOrangeColor
//      UILabel.appearance().font = UIFont(name: "Raleway", size: 15)
        
        //navigation buttons
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : ModernMealOrangeColor, NSFontAttributeName: UIFont(name: "Raleway-Bold", size: 15)!], forState: UIControlState.Highlighted)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : ModernMealGreyColor, NSFontAttributeName: UIFont(name: "Raleway", size: 15)!], forState: UIControlState.Disabled)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : ModernMealOrangeColor, NSFontAttributeName: UIFont(name: "Raleway", size: 15)!], forState: UIControlState.Normal)
        
        //navigation bar and titles
//      UINavigationBar.appearance().barTintColor = UIColor(red: 234.0/255.0, green: 46.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = ModernMealOrangeColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : ModernMealGreenColor, NSFontAttributeName: UIFont(name: "Raleway-Bold", size: 18)!]//reference [1][2]

  

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.tiy.ModernMeal" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ModernMeal", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

//reference [1] : http://stackoverflow.com/questions/25388214/how-do-i-change-navigationbar-font-in-swift
//reference [2] : http://stackoverflow.com/questions/26008536/navigationbar-bar-tint-and-title-text-color-in-ios-8