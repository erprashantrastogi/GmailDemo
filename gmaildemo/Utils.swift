//
//  Utils.swift
//  gmaildemo
//
//  Created by Prashant Rastogi on 04/06/16.
//  Copyright © 2016 Prashant Rastogi. All rights reserved.
//

import UIKit

class Utils: NSObject {

    // Helper for showing an alert
    class func showAlert(title : String, message: String )
    {
        let alert = UIAlertView(
            title: title,
            message: message,
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        alert.show()
    }
    
    class func getDateStr(gmailDate:NSString) -> String
    {
        let newDate = gmailDate.substringToIndex(25);
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        let dateObj =  dateFormatter.dateFromString( newDate ) ;
        
        var newDateStr = "";
        if( dateObj != nil)
        {
            dateFormatter.dateFormat = "hh:mm a"
            dateFormatter.AMSymbol = "AM"
            dateFormatter.PMSymbol = "PM"
            
            newDateStr = dateFormatter.stringFromDate(dateObj!);
        }
        
        return newDateStr;
    }
}
