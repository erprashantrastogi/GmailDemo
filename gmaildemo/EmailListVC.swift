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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getEmails();
    }

    func getEmails()  {
        
        let query = GTLQueryGmail.queryForUsersMessagesList()
        
        query.maxResults = 5;
        query.labelIds = [labelObj.identifier];
        
        service.executeQuery(query)
        {
            [weak self]
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
                
                self?.service.executeQuery(getMsgQuery, completionHandler: { (ticket, messgae, error) in
                    
                    if let error = error {
                        Utils.showAlert("Error", message: error.localizedDescription)
                        return
                    }
                    
                    let msg = messgae as! GTLGmailMessage;
                    self?.arrayOfMessage.append(msg);
                    
                    self?.reloadTable();
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
        let noOfRows:Int = arrayOfMessage.count;
        return noOfRows;
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let emailListCell = tableView.dequeueReusableCellWithIdentifier("EmailListCell", forIndexPath: indexPath) as! EmailListCell;

        // Configure the cell...
        let msg:GTLGmailMessage = self.arrayOfMessage[indexPath.row];
        let payLoad:GTLGmailMessagePart = msg.payload;
        let headers:[GTLGmailMessagePartHeader] = payLoad.headers as! [GTLGmailMessagePartHeader];
        
        for header in headers
        {
            if( header.name == "From" )
            {
                let rangeObj = header.value.rangeOfString("<");
                
                emailListCell.lblSender.text = header.value.substringToIndex((rangeObj?.startIndex)!)
            }
            if(header.name == "Subject")
            {
                emailListCell.lblSubject.text = header.value;
            }
            if(header.name == "Date")
            {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
                let dateObj =  dateFormatter.dateFromString( header.value ) ;
                
                dateFormatter.dateFormat = "hh:mm a"
                dateFormatter.AMSymbol = "AM"
                dateFormatter.PMSymbol = "PM"
                
                emailListCell.lblTime.text = dateFormatter.stringFromDate(dateObj!);
            }
        }
        
        emailListCell.viewOfCircle.layer.cornerRadius = 10.0;

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