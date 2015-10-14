//
//  MapViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/3/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var otmTabBarController: OTMTabBarController!
    var spinner: ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otmTabBarController = tabBarController as! OTMTabBarController
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        otmTabBarController?.navigationController!.navigationBarHidden = false
        otmTabBarController.tabBar.hidden = false
        checkIfLogged()
    }
    
    
    func checkIfLogged() {
        if otmTabBarController.udacityKey == OTMClient.ConstantsGeneral.EMPTY_STR {
            otmTabBarController.tabBar.hidden = true
            performSegueWithIdentifier("LoginSegue", sender: self)
            self.storyboard!.instantiateViewControllerWithIdentifier("OTMFBAuthViewController")
        } 
    }

    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    
    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        
        spinner = ActivityIndicatorView(text: OTMClient.ConstantsMessages.LOGOUT_PROCESSING)
        view.addSubview(spinner)
        
        OTMClient.sharedInstance().udacityPOSTLogout() {
            (success, errorString)  in
            
            var isSuccess: Bool = false
            if (success != nil) {
                let responseAsNSDictinory: Dictionary<String, AnyObject> = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if ((responseAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let message: String = OTMClient.sharedInstance().parseErrorReturned(responseAsNSDictinory)
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
    
    
    func okDismissAlertAndPerformSegue(titleStr titleStr: String, messageStr: String, controller: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.Alert)
        let okDismiss: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: {
                action in self.checkIfLogged()
            })
        alert.addAction(okDismiss)
        controller.presentViewController(alert, animated: true, completion: {})
    }

    
    
    @IBAction func pinAction(sender: AnyObject) {
    }
    
    
    
    @IBAction func refreshAction(sender: AnyObject) {
    }
    
}
