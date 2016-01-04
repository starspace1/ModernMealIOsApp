//
//  GroceryList+CoreDataProperties.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 12/14/15.
//  Copyright © 2015 Pedro Trujillo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension GroceryList {

    @NSManaged var groceryListJSON: String?
    @NSManaged var notesString: String?

}
