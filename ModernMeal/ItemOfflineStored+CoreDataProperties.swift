//
//  ItemOfflineStored+CoreDataProperties.swift
//  ModernMeal
//
//  Created by Pedro Trujillo on 1/7/16.
//  Copyright © 2016 Pedro Trujillo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ItemOfflineStored {

    @NSManaged var itemDictionarystring: String?
    @NSManaged var method: String!

}
