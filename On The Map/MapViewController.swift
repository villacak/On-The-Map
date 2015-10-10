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
            otmTabBarController.udacitySessionId = "Variable Test"
            otmTabBarController.udacityKey = "Key Test"
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
    
    @IBAction func loginAction(sender: AnyObject) {
    }
    
    @IBAction func pinAction(sender: AnyObject) {
    }
    
    @IBAction func refreshAction(sender: AnyObject) {
    }
    
}
