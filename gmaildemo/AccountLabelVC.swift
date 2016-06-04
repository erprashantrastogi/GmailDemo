//
//  AccountLabelVC.swift
//  gmaildemo
//
//  Created by Prashant Rastogi on 04/06/16.
//  Copyright © 2016 Prashant Rastogi. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2

class AccountLabelVC: UITableViewController {

    var userEntity:User!;
    var service:GTLServiceGmail!  ;
    
    var arrayOfLabels:[GTLGmailLabel] = [];
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        fetchAllLabels();
    }
    
    // Construct a query and get a list of upcoming labels from the gmail API
    func fetchAllLabels()
    {
        let query = GTLQueryGmail.queryForUsersLabelsList()
        
        service.executeQuery(query) {
            
            [weak self]
            (ticket, labelsResponse, error) in
            
            if let error = error {
                Utils.showAlert("Error", message: error.localizedDescription)
                return
            }
            
            self?.arrayOfLabels = labelsResponse.labels as! [GTLGmailLabel]
            
            let sortedArray = ((self?.arrayOfLabels)! as NSArray).sortedArrayUsingDescriptors([
                NSSortDescriptor(key: "type", ascending: true),
                NSSortDescriptor(key: "name", ascending: true),
                ]) as! [GTLGmailLabel]
            
            self?.arrayOfLabels = sortedArray
            self?.reloadTable();
        }
        
    }
    
    func reloadTable()  {
        
        let tblView = self.view as! UITableView;
        tblView.reloadData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayOfLabels.count;
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("EmailLabelsCell");
        
        if let _ = cell{
            
        }
        else
        {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "EmailLabelsCell");
        }
        
        cell!.accessoryType = .DisclosureIndicator;
        
        let gTLGmailLabel = arrayOfLabels[indexPath.row] ;
        cell!.textLabel?.text  = gTLGmailLabel.name  ;
        return cell!;
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        let storyboardObj = UIStoryboard(name: "Main", bundle: nil);
        let emailListVC:EmailListVC = storyboardObj.instantiateViewControllerWithIdentifier("EmailListVC") as! EmailListVC;
        
        emailListVC.userEntity = userEntity;
        emailListVC.service = service;
        emailListVC.labelObj = arrayOfLabels[indexPath.row];
        
        self.navigationController?.pushViewController(emailListVC, animated: true);
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
