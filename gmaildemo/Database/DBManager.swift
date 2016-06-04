//
//  DBManager.swift
//  gmaildemo
//
//  Created by Prashant Rastogi on 04/06/16.
//  Copyright © 2016 Prashant Rastogi. All rights reserved.
//

import CoreData
import UIKit

class DBManager: NSObject {

    class func createUserWithKey(keyChainId:String, andEmail emailId:String) -> User
    {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let context:NSManagedObjectContext = appDelegate.managedObjectContext;
        
        // Create Entity
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)
        
        // Initialize Record
        let userEntity = User(entity: entity!, insertIntoManagedObjectContext: context);

        userEntity.keyChainId = keyChainId;
        userEntity.email = emailId;
        
        appDelegate.saveContext();
        
        return userEntity;
    }
    
    class func getSavedUser() -> [User] {
        
        var arrayOfUsers:[User] = [];
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let context:NSManagedObjectContext = appDelegate.managedObjectContext;
        
        // Initialize Record
        let fetchRequest = NSFetchRequest(entityName: "User");
        
        do
        {
            arrayOfUsers = try context.executeFetchRequest(fetchRequest) as! [User];
        }
        catch
        {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return arrayOfUsers;
    }
}
