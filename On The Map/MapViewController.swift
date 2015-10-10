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
        print("MapView viewDidLoad")
        print("MapView Session ID is \(otmTabBarController.udacitySessionId)")
        print("MapView Key ID is \(otmTabBarController.udacityKey)")

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        tabBarController?.navigationController!.navigationBarHidden = true
        otmTabBarController.tabBar.hidden = true
        
        print("MapView viewWillApplear")
        print("MapView Session ID is \(otmTabBarController.udacitySessionId)")
        print("MapView Key ID is \(otmTabBarController.udacityKey)")
        
        checkIfLogged()
    }
    
    
    func checkIfLogged() {
        if otmTabBarController.udacityKey == OTMClient.ConstantsGeneral.EMPTY_STR {
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
    
}
