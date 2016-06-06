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

class EmailListVC: UITableViewController
{
    var userEntity:User!;
    var service:GTLServiceGmail!  ;
    var labelObj:GTLGmailLabel! ;
    
    var arrayOfMessage:[GTLGmailMessage] = [];
    var nextPageToken:String!;
    
    var msgFetchCount:NSNumber = NSNumber(integer: 0);
    override func viewDidLoad() {
        super.viewDidLoad()

        getEmails();
    }

    func getEmails()  {
        
        msgFetchCount = 0;
        
        let query = GTLQueryGmail.queryForUsersMessagesList()
        
        if( nextPageToken != nil)
        {
            query.pageToken = nextPageToken;
        }
        
        query.maxResults = 10;
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
                return;
            }
            let arrayOfMessages = labelsResponse.messages as! [GTLGmailMessage]
            
            if(resultSize.integerValue  > 9)
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
                    
                    if( self.msgFetchCount == 4)
                    {
                        self.reloadTable();
                        self.msgFetchCount = 0;
                    }
                    self.msgFetchCount = NSNumber(integer: self.msgFetchCount.integerValue + 1);
                    
                })
            }
        }
        
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
        let hasNeedToFetchNext = arrayOfMessage.count - 5 == indexPath.row;
        
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
        emailListCell.prepareCell(withMsg: msg);
        
        return emailListCell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
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