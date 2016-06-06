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
    var pageNumber = 0;
    
    var msgFetchCount:NSNumber = NSNumber(integer: 0);
    override func viewDidLoad() {
        super.viewDidLoad()

        getEmails();
    }

    func getEmails()  {
        
        msgFetchCount = 0;
        
        pageNumber++;
        
        let query = GTLQueryGmail.queryForUsersMessagesList()
        
        query.pageToken = String(pageNumber);
        query.maxResults = 5;
        query.labelIds = [labelObj.identifier];
        
        service.executeQuery(query)
        {
            //[weak self]
            (ticket, labelsResponse, error) in
            
            if let error = error {
                Utils.showAlert("Error", message: error.localizedDescription)
                return
            }
            
            let arrayOfMessages = labelsResponse.messages as! [GTLGmailMessage]
            
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
                    
                    /*
                    let payLoad:GTLGmailMessagePart = msg.payload;
                    
                    let headers:[GTLGmailMessagePartHeader] = payLoad.headers as! [GTLGmailMessagePartHeader];
                    
                    for header in headers
                    {
                        if( header.name == "From" || header.name == "Subject" || header.name == "Date")
                        {
                            print(header.name + " : " + header.value )
                        }
                    }
                    
                    print("\n============================\n");*/
                    /*
                     let bodyObj:GTLGmailMessagePartBody = payLoad.body;
                     
                     let bodyData : String? = bodyObj.data
                     
                     if bodyData != nil
                     {
                     
                     let decodedData = GTLDecodeWebSafeBase64(bodyData)
                     let decodedString = NSString(data: decodedData!, encoding: NSUTF8StringEncoding)
                     
                     print("after decoded: \(decodedString)")
                     print("\n============================\n");
                     }
                     */
                    
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
            noOfRows = arrayOfMessage.count + 1;
        }
        
        return noOfRows;
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.row == arrayOfMessage.count && pageNumber != 0
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