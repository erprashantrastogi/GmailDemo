//
//  Utils.swift
//  gmaildemo
//
//  Created by Prashant Rastogi on 04/06/16.
//  Copyright © 2016 Prashant Rastogi. All rights reserved.
//

import UIKit
import MBProgressHUD

class Utils: NSObject {

    class func showProgressBar()  {
        
        let window = UIApplication.sharedApplication().delegate?.window!
        MBProgressHUD.showHUDAddedTo(window, animated: true)
    }
    
    class func hideProgressBar()  {
        
        dispatch_async(dispatch_get_main_queue()) { 
            
            let window = UIApplication.sharedApplication().delegate?.window!
            MBProgressHUD.hideHUDForView(window, animated: true)
            
        }
        
    }
    
    // Helper for showing an alert
    class func showAlert(title : String, message: String )
    {
         Utils.hideProgressBar();
        let alert = UIAlertView(
            title: title,
            message: message,
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        alert.show()
    }
    
    class func getDateStr(gmailDate:NSString) -> NSString
    {
        /*
        let dateObj = NSDate(timeIntervalSince1970: NSTimeInterval(gmailDate));
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.AMSymbol = "AM"
        dateFormatter.PMSymbol = "PM"
        
        let newDateStr = dateFormatter.stringFromDate(dateObj);
        return newDateStr;
        */
        
        let newDate:String;
        if( gmailDate.length > 29 )
        {
            newDate = gmailDate.substringToIndex(30);
        }
        else
        {
            newDate = gmailDate.substringToIndex(25);
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZ"
        let dateObj =  dateFormatter.dateFromString( newDate ) ;
        
        var newDateStr = "";
        if( dateObj != nil)
        {
            let today:NSDate = NSDate()
            let order = NSCalendar.currentCalendar().compareDate(today, toDate: dateObj!,
                                                                 toUnitGranularity: .Day)
            
            switch order
            {
            case .OrderedDescending,.OrderedAscending:
                dateFormatter.dateFormat = "dd MMM"
                break
            case .OrderedSame:
                
                dateFormatter.dateFormat = "hh:mm a"
            }
            
            //dateFormatter.dateFormat = "hh:mm a"
            dateFormatter.AMSymbol = "AM"
            dateFormatter.PMSymbol = "PM"
            
            newDateStr = dateFormatter.stringFromDate(dateObj!);
        }
        
        return newDateStr;
    }
}
