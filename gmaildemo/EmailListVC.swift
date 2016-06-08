//
//  EmailListVC.swift
//  gmaildemo
//
//  Created by Prashant Rastogi on 04/06/16.
//  Copyright © 2016 Prashant Rastogi. All rights reserved.
//

import GoogleAPIClient
import GTMOAuth2
import UIKit
import SSToastView

class EmailListVC: UITableViewController
{
    var userEntity:User!;
    var service:GTLServiceGmail!  ;
    var labelObj:GTLGmailLabel! ;
    
    var arrayOfMessage:[GTLGmailMessage] = [];
    var nextPageToken:String!;
    
    var arrayOfSelectedMsg:NSMutableSet = [];
    var msgFetchCount:NSNumber = NSNumber(integer: 0);
    
    func findMsgWithId(id:String) -> GTLGmailMessage?
    {
        var gTLGmailMessage:GTLGmailMessage?
        
        for msg:GTLGmailMessage in arrayOfMessage {
            
            if msg.identifier == id
            {
                gTLGmailMessage = msg
                break
            }
        }
        
        return gTLGmailMessage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let btnDelete = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(onTapDeleteBtn))
        
        let imageObj = UIImage(named: "archieve");
        
        let button = UIButton(type: .Custom);
        button.setBackgroundImage(imageObj?.stretchableImageWithLeftCapWidth(7, topCapHeight: 0), forState: UIControlState.Normal)
        button.setBackgroundImage(imageObj, forState: .Normal);
        
        button.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
        
        button.addTarget(self, action: #selector(EmailListVC.onTapArchieveBtn), forControlEvents: UIControlEvents.TouchUpInside)
        
        let customView = UIView(frame:  button.frame );
        customView.addSubview(button);
        
        let btnMarkAsArchieve = UIBarButtonItem(customView: customView);
        btnMarkAsArchieve.setBackgroundImage(UIImage(named: "archieve"), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        navigationItem.rightBarButtonItems = [btnMarkAsArchieve,btnDelete]
        
        Utils.showProgressBar();
        getEmails();
    }

    func onTapArchieveBtn()
    {
        if arrayOfSelectedMsg.count == 0
        {
            SSToastView.show("Please select at least one message")
            return
        }
        
        let query = GTLQueryGmail.queryForUsersMessagesModify()
        
        var counter = 0
        Utils.showProgressBar();
        for messageId in arrayOfSelectedMsg
        {
            query.identifier = messageId as! String;
            
            let msgObj = findMsgWithId(messageId as! String);
            query.removeLabelIds = msgObj?.labelIds
            
            
            service.executeQuery(query, completionHandler: { (ticket, response, error) -> Void in
                
                counter += 1;
                
                if let error = error {
                    Utils.showAlert("Error", message: error.localizedDescription)
                    return
                }
                
                if( counter == self.arrayOfSelectedMsg.count)
                {
                    SSToastView.show("Selected messages move to archieve.")
                    
                    self.nextPageToken = nil;
                    self.arrayOfSelectedMsg = []
                    self.arrayOfMessage = []
                    self.getEmails();
                }
            })
        }
    }
    func onTapDeleteBtn()
    {
        if arrayOfSelectedMsg.count == 0
        {
            SSToastView.show("Please select at least one message")
            return
        }
        
        Utils.showProgressBar();
        let query = GTLQueryGmail.queryForUsersMessagesBatchDelete()
        query.ids = arrayOfSelectedMsg.allObjects;
        
        service.executeQuery(query) { (ticket, responseObj, errorObj) in
            
            if let error = errorObj {
                Utils.showAlert("Error", message: error.localizedDescription)
                return
            }
            
            SSToastView.show("Selected messages deleted.")
            
            self.nextPageToken = nil;
            self.arrayOfSelectedMsg = []
            self.arrayOfMessage = []
            self.getEmails();
        }
        
    }
    
    
    func getEmails()  {
        
        msgFetchCount = 0;
        
        let query = GTLQueryGmail.queryForUsersMessagesList()
        
        if( nextPageToken != nil)
        {
            query.pageToken = nextPageToken;
        }
        
        query.maxResults = 100;
        query.labelIds = [labelObj.identifier];
        
        service.executeQuery(query)
        {
            //[weak self]
            (ticket, labelsResponse, error) in
            
            if let error = error {
                
                Utils.showAlert("Error", message: error.localizedDescription)
                return
            }
            
            let resultSize = labelsResponse.resultSizeEstimate as NSNumber;
            
            if( resultSize == 0)
            {
                Utils.hideProgressBar()
                return;
            }
            let arrayOfMessages = labelsResponse.messages as! [GTLGmailMessage]
            
            if(resultSize.integerValue  > 99)
            {
                self.nextPageToken = labelsResponse.nextPageToken;
            }
            else
            {
                self.nextPageToken = nil
            }
            for msg:GTLGmailMessage in arrayOfMessages
            {
                let getMsgQuery = GTLQueryGmail.queryForUsersMessagesGet()
                getMsgQuery.identifier = msg.threadId;
                
                self.service.executeQuery(getMsgQuery, completionHandler: {
                    
                    //[weak self]
                    (ticket, messgae, error) in
                    
                    if let error = error {
                        Utils.showAlert("Error", message: error.localizedDescription)
                        return
                    }
                    
                    let msg = messgae as! GTLGmailMessage;
                    self.arrayOfMessage.append(msg);
                    
                    if( self.msgFetchCount.integerValue >= arrayOfMessages.count - 1)
                    {
                        self.reloadTable();
                        self.msgFetchCount = 0;
                         Utils.hideProgressBar()
                    }
                    self.msgFetchCount = NSNumber(integer: self.msgFetchCount.integerValue + 1);
                    if( self.msgFetchCount.integerValue >= arrayOfMessages.count - 1)
                    {
                        self.reloadTable();
                        self.msgFetchCount = 0;
                        Utils.hideProgressBar()
                    }
                })
            }
        }
        
    }
    
    func readStatusChanged()
    {
        self.nextPageToken = nil;
        self.arrayOfSelectedMsg = []
        self.arrayOfMessage = []
        self.getEmails();
    }
    
    func reloadTable()
    {
        let sortedArray = ((self.arrayOfMessage) as NSArray).sortedArrayUsingDescriptors([
            NSSortDescriptor(key: "internalDate", ascending: false)
            ]) as! [GTLGmailMessage]
        
        self.arrayOfMessage = sortedArray;
        let tblView = self.view as! UITableView;
        tblView.reloadData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var noOfRows:Int = 0;
        
        if( arrayOfMessage.count > 0)
        {
            if(self.nextPageToken != nil)
            {
                noOfRows = arrayOfMessage.count + 1;
            }
            else
            {
                noOfRows = arrayOfMessage.count
            }
        }
        
        return noOfRows;
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let hasNeedToFetchNext = arrayOfMessage.count - 50 == indexPath.row && indexPath.row > 0;
        
        if( hasNeedToFetchNext &&  nextPageToken != nil)
        {
            getEmails();
        }
        
        if indexPath.row == arrayOfMessage.count && nextPageToken != nil
        {
            // Need to show Pagination Loader
            var defaultCell = tableView.dequeueReusableCellWithIdentifier("MoreCell") ;
            if( defaultCell == nil)
            {
                defaultCell = UITableViewCell(style: .Default, reuseIdentifier: "MoreCell");
            }
            defaultCell?.textLabel?.text = "Loading More Data";
            
            getEmails();
            return defaultCell!;
        }
        let emailListCell = tableView.dequeueReusableCellWithIdentifier("EmailListCell", forIndexPath: indexPath) as! EmailListCell;

        // Configure the cell...
        let msg:GTLGmailMessage = self.arrayOfMessage[indexPath.row ];
        
        emailListCell.service = service
        emailListCell.tblEmailListVC = self;
        emailListCell.prepareCell(withMsg: msg);
        
        return emailListCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        arrayOfSelectedMsg.addObject(arrayOfMessage[indexPath.row].identifier)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        arrayOfSelectedMsg.removeObject(arrayOfMessage[indexPath.row].identifier)
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            let gTLGmailMessage:GTLGmailMessage = arrayOfMessage[indexPath.row];
            
            let query = GTLQueryGmail.queryForUsersMessagesDelete()
            query.identifier = gTLGmailMessage.identifier;
            
            service.executeQuery(query, completionHandler: { (ticker, responseObj, error) in
                
                if let error = error {
                    Utils.showAlert("Error", message: error.localizedDescription)
                    return
                }
                else
                {
                    Utils.showAlert("Deleter", message: "Message Deleted")
                    self.arrayOfMessage.removeAtIndex(indexPath.row);
                    
                    // Delete the row from the data source
                    //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    self.reloadTable();
                }
                
            })
        }
        else if editingStyle == .Insert
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}