import GoogleAPIClient
import GTMOAuth2
import UIKit
import CoreData

class HomeVC: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var tblUserAccounts: UITableView!
    
    var selectedIndex = 0;
    
    var arrayOfUsers:[User] = [];
    
    private var kKeychainItemName = "Gmail_User"
    private let kClientID = "689504847469-s7n6gra7gv3m3ump0dmelur7na8qc0nv.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLAuthScopeGmailReadonly,kGTLAuthScopeGmailModify,kGTLAuthScopeGmail]
    
    var arrayOfServiceAccounts:[GTLServiceGmail] = [];
    private var service:GTLServiceGmail = GTLServiceGmail() ;
    //let output = UITextView()
    
    // When the view loads, create necessary subviews
    // and initialize the Gmail API service
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        arrayOfUsers = DBManager.getSavedUser();
        fillServiceAccounts();
        tblUserAccounts.tableFooterView = UIView();
    }
    
    func fillServiceAccounts()
    {
        let noOfAccounts = arrayOfUsers.count;
        var itr = 0;
        
        var keyChainId = "";
        
        while itr < noOfAccounts {
            
            keyChainId = arrayOfUsers[itr].keyChainId!;
            
            let serviceObj = GTLServiceGmail();
            if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
                keyChainId,
                clientID: kClientID,
                clientSecret: nil)
            {
                serviceObj.authorizer = auth
            }
            
            arrayOfServiceAccounts.insert(serviceObj, atIndex: itr);
            
            itr += 1;
            
        }
    }
    
    // Creates the auth controller for authorizing access to Gmail API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch
    {
        service = GTLServiceGmail();
        
        kKeychainItemName = "Gmail_User_\(arrayOfUsers.count)";
        let scopeString = scopes.joinWithSeparator(" ");
        
        return GTMOAuth2ViewControllerTouch(scope: scopeString, clientID: kClientID, clientSecret: nil, keychainItemName: kKeychainItemName) {
            
            [weak self]
            (viewController, authResult, errorObj) in
            
            if let error = errorObj
            {
                self?.service.authorizer = nil
                Utils.showAlert("Authentication Error", message: error.localizedDescription)
                return
            }
            
            self?.service.authorizer = authResult
            
            self?.arrayOfServiceAccounts.append((self?.service)!);
            self?.dismissViewControllerAnimated(true, completion: nil)
            
            Utils.showProgressBar()
            self?.getUserProfile()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserProfile()
    {
        let query = GTLQueryGmail.queryForUsersGetProfile();
        
        service.executeQuery(query) { (ticket, labelsResponse, error) -> Void in
            
            if let error = error {
                Utils.showAlert("Error", message: error.localizedDescription)
                return
            }
            
            let response = labelsResponse as? GTLGmailProfile;
            let emailId = response?.emailAddress;
            
            let user = DBManager.createUserWithKey(self.kKeychainItemName, andEmail: emailId!);
            self.arrayOfUsers.append(user);
            self.tblUserAccounts.reloadData();
            
            Utils.hideProgressBar()
        }
        
    }
    
    @IBAction func onTapAddEmail(sender: UIBarButtonItem)
    {
        self.navigationController?.pushViewController(createAuthController(), animated: true);
    }
    
    // MARK: TableViewDataSource Delegate
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayOfUsers.count;
    }
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("EmailAccountCell");
        
        if let _ = cell{
            
        }
        else
        {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "EmailAccountCell");
        }
        
        cell!.accessoryType = .DisclosureIndicator;
        
        let userEntity = arrayOfUsers[indexPath.row] ;
        cell!.textLabel?.text = userEntity.email;
        return cell!;
    }
    
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let rowNo = indexPath.row;
        
        var gTLServiceGmail = GTLServiceGmail();
        
        if( rowNo < arrayOfServiceAccounts.count)
        {
            gTLServiceGmail = arrayOfServiceAccounts[rowNo];
        }
        else
        {
            let keyChainId = arrayOfUsers[rowNo].keyChainId;
            
            if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
                  keyChainId,
                  clientID: kClientID,
                  clientSecret: nil)
            {
                gTLServiceGmail.authorizer = auth
            }
            
            arrayOfServiceAccounts.insert(gTLServiceGmail, atIndex: indexPath.row);
        }
        
        
        service = gTLServiceGmail;
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedIndex = indexPath.row;
        self.performSegueWithIdentifier("MoveToLabelsVC", sender: self);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "MoveToLabelsVC"
        {
            let accountLabelVC:AccountLabelVC = segue.destinationViewController as! AccountLabelVC;
            
            if( selectedIndex < arrayOfUsers.count )
            {
                accountLabelVC.userEntity = arrayOfUsers[selectedIndex];
                
            }
            if(selectedIndex < arrayOfServiceAccounts.count)
            {
                accountLabelVC.service = arrayOfServiceAccounts[selectedIndex];
            }
        }
        
    }
    
    // Override to support editing the table view.
    internal func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            let userEntity = arrayOfUsers[indexPath.row];
            arrayOfUsers.removeAtIndex(indexPath.row);
            
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
            let context:NSManagedObjectContext = appDelegate.managedObjectContext;
            
            context.deleteObject(userEntity);
            appDelegate.saveContext();
            
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            
        }
        else if editingStyle == .Insert
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
}