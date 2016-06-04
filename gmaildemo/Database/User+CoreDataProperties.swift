//
//  User+CoreDataProperties.swift
//  
//
//  Created by Prashant Rastogi on 04/06/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var keyChainId: String?
    @NSManaged var email: String?

}
