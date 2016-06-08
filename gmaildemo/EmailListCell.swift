//
//  EmailListCell.swift
//  gmaildemo
//
//  Created by Prashant Rastogi on 04/06/16.
//  Copyright © 2016 Prashant Rastogi. All rights reserved.
//

import UIKit
import GoogleAPIClient
import SSToastView

class EmailListCell: UITableViewCell {

    @IBOutlet weak var viewOfCircle: UIView!
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var lblMsgDesc: UILabel!
    @IBOutlet weak var btnRead: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    
    var messageObj:GTLGmailMessage!
    var service:GTLServiceGmail!  ;
    var tblEmailListVC:EmailListVC!
    
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
    
    func prepareCell(withMsg message:GTLGmailMessage)
    {
        messageObj = message;
        var  hasMsgUnRead = false
        
        for labelId in messageObj.labelIds {
            if labelId as! String == "UNREAD"
            {
                hasMsgUnRead = true;
            }
        }
        
        viewOfCircle.hidden = !hasMsgUnRead;
        
        let imageName = hasMsgUnRead ? "unread" : "read";
        let imgObj = UIImage(named: imageName)
        
        btnRead.setBackgroundImage(imgObj, forState: UIControlState.Normal)
        
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
    
    @IBAction func onTapReadUnreadBtn(sender: UIButton) {
        
        var  hasMsgUnRead = false
        
        for labelId in messageObj.labelIds {
            if labelId as! String == "UNREAD"
            {
                hasMsgUnRead = true;
            }
        }
        
        if( hasMsgUnRead )
        {
            // Mark Msg as Read
            let query = GTLQueryGmail.queryForUsersMessagesModify()
            query.identifier = messageObj.identifier;
            
            query.removeLabelIds = ["UNREAD"]
            service.executeQuery(query, completionHandler: { (ticket, response, error) -> Void in
                
                if let error = error {
                    Utils.showAlert("Error", message: error.localizedDescription)
                    return
                }
                self.tblEmailListVC.readStatusChanged();
                SSToastView.show("Message mark as read.");
            })
        }
        else
        {
            // Mark Msg as UnRead
            let query = GTLQueryGmail.queryForUsersMessagesModify()
            query.identifier = messageObj.identifier;
            
            query.addLabelIds = ["UNREAD"]
            service.executeQuery(query, completionHandler: { (ticket, response, error) -> Void in
                
                if let error = error {
                    Utils.showAlert("Error", message: error.localizedDescription)
                    return
                }
                self.tblEmailListVC.readStatusChanged();
                SSToastView.show("Message mark as unread.");
            })
        }
        
    }
    

}
