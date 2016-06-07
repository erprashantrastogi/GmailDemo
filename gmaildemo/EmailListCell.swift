//
//  EmailListCell.swift
//  gmaildemo
//
//  Created by Prashant Rastogi on 04/06/16.
//  Copyright © 2016 Prashant Rastogi. All rights reserved.
//

import UIKit
import GoogleAPIClient

class EmailListCell: UITableViewCell {

    @IBOutlet weak var viewOfCircle: UIView!
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var lblMsgDesc: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareCell(withMsg messageObj:GTLGmailMessage)
    {
        var  hasMsgUnRead = false
        
        for labelId in messageObj.labelIds {
            if labelId as! String == "UNREAD"
            {
                hasMsgUnRead = true;
            }
        }
        
        viewOfCircle.hidden = !hasMsgUnRead;
        
        let snippet = messageObj.snippet;
        let payLoad:GTLGmailMessagePart = messageObj.payload;
        let headers:[GTLGmailMessagePartHeader] = payLoad.headers as! [GTLGmailMessagePartHeader];
        
        for header in headers
        {
            if( header.name == "From" )
            {
                if( header.value != nil )
                {
                    let rangeObj = header.value.rangeOfString("<");
                    if( rangeObj != nil)
                    {
                        lblSender.text = header.value.substringToIndex((rangeObj?.startIndex)!)
                        
                    }
                }
            }
            if(header.name == "Subject")
            {
                lblSubject.text = header.value;
            }
            if(header.name == "Date")
            {
                lblTime.text = Utils.getDateStr(header.value) as String;
            }
            
            print( header.name + " : " + header.value);
        }
        lblMsgDesc.text = snippet;
        viewOfCircle.layer.cornerRadius = 10.0;
    }

}
