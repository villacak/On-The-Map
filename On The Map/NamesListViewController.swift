//
//  NamesListViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/25/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import Parse
import MapKit

class NamesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var postingButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    let reusableCell: String = "BasicCell"
    
    var spinner: ActivityIndicatorView!
    var otmTabBarController: OTMTabBarController!

    
    //
    // Call when view just have loaded
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        otmTabBarController = tabBarController as! OTMTabBarController
    }
    
    
    //
    // Called when view will appear
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        loadData(numberToLoad: OTMClient.ConstantsParse.PAGINATION, cacheToPaginate: OTMClient.ConstantsGeneral.EMPTY_STR, orderListBy: OTMServicesNameEnum.updateAt)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
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
        let okDismiss: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: {
            action in self.checkIfLogged()
        })
        alert.addAction(okDismiss)
        controller.presentViewController(alert, animated: true, completion: {})
    }


    //
    // Check if the user is logged
    //
    func checkIfLogged() {
        if otmTabBarController.udacityKey == OTMClient.ConstantsGeneral.EMPTY_STR {
            otmTabBarController.tabBar.hidden = true
            navigationController?.navigationBarHidden = true
            otmTabBarController.selectedIndex = 0;
        }
    }

    //
    // Return the number if rows in to be displayed
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otmTabBarController.mapPoints.count
    }
    
    
    //
    // Assemble the cell to the row
    //
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let pointObject: MKPointAnnotation = otmTabBarController.mapPoints[indexPath.row]
        let cell: ListUserData = (tableView.dequeueReusableCellWithIdentifier(reusableCell, forIndexPath: indexPath)) as! ListUserData
        
        cell.keyValue.text = String(indexPath.row)
        cell.fullName.text = pointObject.title
        return cell
    }
    
    
    //
    // Called when user did selected a row
    //
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let pointObject: MKPointAnnotation = otmTabBarController.mapPoints[indexPath.row]
        if pointObject.subtitle! == OTMClient.ConstantsGeneral.EMPTY_STR {
            Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.ERROR_TITLE, messageStr: OTMClient.ConstantsMessages.NO_URL_DEFINED, controller: self)
        } else {
            print(pointObject.subtitle!)
            let urlAsString: String = pointObject.subtitle!
            let app = UIApplication.sharedApplication()
            if (urlAsString.containsString(OTMClient.ConstantsRequest.HTTP_START_WITH)) {
                app.openURL(NSURL(string: urlAsString)!)
            } else {
                app.openURL(NSURL(string: "http://\(urlAsString)")!)
            }
            app.openURL(NSURL(string: pointObject.subtitle!)!)
        }
    }
  
    
    //
    // Logout
    //
    @IBAction func logoutAction(sender: AnyObject) {
        startSpin(spinText: OTMClient.ConstantsMessages.LOGOUT_PROCESSING)
        
        otmTabBarController.logout() {(result, error) in
            var isSuccess = false
            if let tempError = error {
                Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOGOUT_FAILED, messageStr: (tempError.description), controller: self)
            } else {
                isSuccess = true
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                // Dismiss modal
                self.spinner.hide()
                
                // If success extracting data then call the TabBarController Map view
                if (isSuccess) {
                    self.otmTabBarController.udacitySessionId = OTMClient.ConstantsGeneral.EMPTY_STR
                    self.otmTabBarController.udacityKey = OTMClient.ConstantsGeneral.EMPTY_STR
                    self.otmTabBarController.loggedOnUdacity = false
                    self.okDismissAlertAndPerformSegue(titleStr: OTMClient.ConstantsMessages.LOGOUT_SUCCESS, messageStr: OTMClient.ConstantsMessages.LOGOUT_SUCCESS_MESSAGE, controller: self)
                }
            }
        }
    }
    
    
    //
    // Post a new update
    //
    @IBAction func postingAction(sender: AnyObject) {
        navigationController?.navigationBarHidden = false
        otmTabBarController.tabBar.hidden = true
        performSegueWithIdentifier("PostingViewSegue2", sender: self)
        storyboard!.instantiateViewControllerWithIdentifier("PostingView") as! PostingViewController
    }
    
    
    //
    // Refresh button
    //
    @IBAction func refreshAction(sender: AnyObject) {
        loadData(numberToLoad: OTMClient.ConstantsParse.PAGINATION, cacheToPaginate: OTMClient.ConstantsGeneral.EMPTY_STR, orderListBy: OTMServicesNameEnum.updateAt)
    }
    
    
    //
    // Load data from Parse
    //
    func loadData(numberToLoad numberToLoad: String, cacheToPaginate: String, orderListBy: OTMServicesNameEnum) {
        startSpin(spinText: OTMClient.ConstantsMessages.LOADING_DATA)
        
        otmTabBarController.loadData(numberToLoad: numberToLoad, cacheToPaginate: cacheToPaginate, orderListBy: orderListBy) { (result, error) in
            
            var isSuccess = false
            if let tempError = error {
                Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOADING_DATA_FAILED, messageStr: (tempError.description), controller: self)
            } else {
                isSuccess = true
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                // Dismiss modal
                self.spinner.hide()
                
                // If success extracting data then call the TabBarController Map view
                if (isSuccess) {
                    self.tableView.reloadData()
                }
            }
        }
    }
}
