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
    
}
