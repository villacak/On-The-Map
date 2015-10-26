//
//  NamesListViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/25/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit

class NamesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var postingButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    let reusableCell: String = "BasicCell"
    
    var spinner: ActivityIndicatorView!
    var otmTabBarController: OTMTabBarController!
    var keys: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        otmTabBarController = tabBarController as! OTMTabBarController
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        keys = Array(otmTabBarController.userDataDic.keys)
    }
    
    
    //
    // Add view to show the spin
    //
    func startSpin(spinText spinText: String) {
        spinner = ActivityIndicatorView(text: spinText)
        view.addSubview(spinner)
    }
    
    
    //
    // Dismiss the Allert and form the segue
    //
    func okDismissAlertAndPerformSegue(titleStr titleStr: String, messageStr: String, controller: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.Alert)
        let okDismiss: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(okDismiss)
        controller.presentViewController(alert, animated: true, completion: {})
    }


    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otmTabBarController.userDataDic.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let keyForGetFromDictionary: String = keys[indexPath.row]
        let userDataTemp: UserData = otmTabBarController.userDataDic[keyForGetFromDictionary]!
        let cell: ListUserData = (tableView.dequeueReusableCellWithIdentifier(reusableCell, forIndexPath: indexPath)) as! ListUserData
        cell.keyValue.text = keyForGetFromDictionary
        cell.fullName.text = "\(userDataTemp.firstName) \(userDataTemp.lastName)"
        return cell
    }
    
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let keyForGetFromDictionary: String = keys[indexPath.row]
        let userDataTemp: UserData = otmTabBarController.userDataDic[keyForGetFromDictionary]!
        
        if userDataTemp.mediaUrl == OTMClient.ConstantsGeneral.EMPTY_STR {
            Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.ERROR_TITLE, messageStr: OTMClient.ConstantsMessages.NO_URL_DEFINED, controller: self)
        } else {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: userDataTemp.mediaUrl)!)
        }
    }
  
    
    @IBAction func logoutAction(sender: AnyObject) {
        startSpin(spinText: OTMClient.ConstantsMessages.LOGOUT_PROCESSING)
        
        OTMClient.sharedInstance().udacityPOSTLogout() {
            (success, errorString)  in
            
            var isSuccess: Bool = false
            var responseLogoutAsNSDictinory: Dictionary<String, AnyObject>!
            if (success != nil) {
                responseLogoutAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if ((responseLogoutAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let message: String = OTMClient.sharedInstance().parseErrorReturned(responseLogoutAsNSDictinory)
                    Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOGIN_FAILED, messageStr: message, controller: self)
                } else {
                    isSuccess = true
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOGIN_FAILED, messageStr: (errorString?.description)!, controller: self)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                // Dismiss modal
                self.spinner.hide()
                
                // If success extracting data then call the TabBarController Map view
                if (isSuccess) {
                    self.otmTabBarController.udacitySessionId = OTMClient.ConstantsGeneral.EMPTY_STR
                    self.otmTabBarController.udacityKey = OTMClient.ConstantsGeneral.EMPTY_STR
                    self.otmTabBarController.loggedOnUdacity = false
                    self.navigationController?.navigationBarHidden = true
                    self.okDismissAlertAndPerformSegue(titleStr: OTMClient.ConstantsMessages.LOGOUT_SUCCESS, messageStr: OTMClient.ConstantsMessages.LOGOUT_SUCCESS_MESSAGE, controller: self)
                }
            })
        }

    }
    
    
    @IBAction func postingAction(sender: AnyObject) {
    }
    
    
    @IBAction func refreshAction(sender: AnyObject) {
//        let checkUserDataTemp: UserData? = otmTabBarController.userDataDic[otmTabBarController.udacityKey]
//        if (checkUserDataTemp == nil) {
//            loadUserData()
//        } else {
//            loadData(numberToLoad: paginationSize, cacheToPaginate: initialCache, orderListBy: OTMServicesNameEnum.updateAt)
//        }
    }
    
}
