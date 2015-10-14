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
    
    
//    var activityIndicatorView: ActivityIndicatorView!
    var otmTabBarController: OTMTabBarController!
    
    
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
//            otmTabBarController.udacitySessionId = "Variable Test"
//            otmTabBarController.udacityKey = "Key Test"
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
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        OTMClient.sharedInstance().udacityPOSTLogout() {
            (success, errorString)  in
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
            
            if (success != nil) {
                let responseAsNSDictinory: Dictionary<String, AnyObject> = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if ((responseAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let message: String = OTMClient.sharedInstance().parseErrorReturned(responseAsNSDictinory)
                     Dialog().okDismissAlert(titleStr: "Login Failed", messageStr: message, controller: self)
                } else {
                    let isSuccess = OTMClient.sharedInstance().successResponse(responseAsNSDictinory, otmTabBarController: self.otmTabBarController)
                    
                    // If success extracting data then call the TabBarController Map view
                    if (isSuccess) {
                        self.otmTabBarController.udacitySessionId = OTMClient.ConstantsGeneral.EMPTY_STR
                        self.otmTabBarController.udacityKey = OTMClient.ConstantsGeneral.EMPTY_STR
                        self.navigationController?.navigationBarHidden = false
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                Dialog().okDismissAlert(titleStr: "Login Failed", messageStr: (errorString?.description)!, controller: self)
            }
            
        }
       

    }
    
    @IBAction func pinAction(sender: AnyObject) {
    }
    
    @IBAction func refreshAction(sender: AnyObject) {
    }
    
}
