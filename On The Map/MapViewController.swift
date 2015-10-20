//
//  MapViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/3/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    let locationManager = CLLocationManager()
    let paginationSize: String = "100"
    let initialCache: String = "400"
    
    var locationList: [MKPointAnnotation]!
    var otmTabBarController: OTMTabBarController!
    var spinner: ActivityIndicatorView!
    var mapPoints: [MKAnnotation]!
    var responseAsNSDictinory: Dictionary<String, AnyObject>!
    var userLocation: CLLocationCoordinate2D!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otmTabBarController = tabBarController as! OTMTabBarController
        
        mapView.mapType = MKMapType.Standard
//        mapView.removeAnnotation(mapView.annotations)
        
        // Acquire user geo position
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        otmTabBarController.tabBar.hidden = false
        checkIfLogged()
    }
    
    
    func checkIfLogged() {
        if otmTabBarController.udacityKey == OTMClient.ConstantsGeneral.EMPTY_STR {
            otmTabBarController.tabBar.hidden = true
            performSegueWithIdentifier("LoginSegue", sender: self)
            self.storyboard!.instantiateViewControllerWithIdentifier("OTMFBAuthViewController")
        } else {
            loadData(numberToLoad: paginationSize, cacheToPaginate: initialCache, orderListBy: OTMServicesNameEnum.updateAt)
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
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = manager.location?.coordinate
        
        let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
        let currentLocation: CLLocation = CLLocation()
        
        let locationLat = currentLocation.coordinate.latitude
        let locationLon = currentLocation.coordinate.longitude
        
        print("Locations: Latitude = \(locationLat), Longitude = \(locationLon), Current Location Lat/Lon= \(currentLocation.coordinate.latitude) \\ \(currentLocation.coordinate.longitude)")
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let message: String = OTMClient.ConstantsMessages.ERROR_UPDATING_LOCATION + error.localizedDescription
        Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOADING_DATA_FAILED, messageStr: message, controller: self)
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        startSpin(spinText: OTMClient.ConstantsMessages.LOGOUT_PROCESSING)
        
        OTMClient.sharedInstance().udacityPOSTLogout() {
            (success, errorString)  in
            
            var isSuccess: Bool = false
            if (success != nil) {
                self.responseAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if ((self.responseAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let message: String = OTMClient.sharedInstance().parseErrorReturned(self.responseAsNSDictinory)
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
    
    
    func loadData(numberToLoad numberToLoad: String, cacheToPaginate: String, orderListBy: OTMServicesNameEnum) {
        startSpin(spinText: OTMClient.ConstantsMessages.LOADING_DATA)
        
        OTMClient.sharedInstance().parseGETStudentLocations(limit: numberToLoad, skip: cacheToPaginate, order: orderListBy){
            (success, errorString)  in
            var isSuccess: Bool = false
            if (success != nil) {
                self.responseAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if ((self.responseAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let message: String = OTMClient.sharedInstance().parseErrorReturned(self.responseAsNSDictinory)
                    Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOADING_DATA_FAILED, messageStr: message, controller: self)
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
                    self.populateLocationList()
                }
            })
        }
    }
    
    
    
    func startSpin(spinText spinText: String) {
        spinner = ActivityIndicatorView(text: spinText)
        view.addSubview(spinner)
    }
    
    
    func populateLocationList() {
        let results: [AnyObject] = responseAsNSDictinory[OTMClient.ConstantsParse.RESULTS] as! [AnyObject]
        print("results : \(results)")
        print(responseAsNSDictinory!)
    }
    
    
    @IBAction func pinAction(sender: AnyObject) {
        navigationController?.navigationBarHidden = false
        otmTabBarController.tabBar.hidden = true
        performSegueWithIdentifier("PostingViewSegue", sender: self)
        storyboard!.instantiateViewControllerWithIdentifier("PostingView")
    }
    
    
    
    @IBAction func refreshAction(sender: AnyObject) {
        checkIfLogged()
    }
    
}
