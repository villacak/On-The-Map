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
    
    
    // View Did Load - Runs this function
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
    
    
    // Calles just before view will appear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        otmTabBarController.tabBar.hidden = false
        checkIfLogged()
    }
    
    
    // Check if the user have already logged or not, if logged load data, if not redirect to the login page
    func checkIfLogged() {
        if otmTabBarController.udacityKey == OTMClient.ConstantsGeneral.EMPTY_STR {
            otmTabBarController.tabBar.hidden = true
            performSegueWithIdentifier("LoginSegue", sender: self)
            self.storyboard!.instantiateViewControllerWithIdentifier("OTMFBAuthViewController")
        } else {
            let checkUserDataTemp: UserData? = otmTabBarController.userDataDic[otmTabBarController.udacityKey]
            if (checkUserDataTemp == nil) {
                loadUserData()
            }
            loadData(numberToLoad: paginationSize, cacheToPaginate: initialCache, orderListBy: OTMServicesNameEnum.updateAt)
            
        }
    }

    
    // Called whe nmap view has finished to load
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    
    // Called when mapview will start to load
    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    
    // Location Manager called when locations have been updated
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
    
    
    // Location Manager called when error occur when loading locations
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let message: String = OTMClient.ConstantsMessages.ERROR_UPDATING_LOCATION + error.localizedDescription
        Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOADING_DATA_FAILED, messageStr: message, controller: self)
    }
    
    
    // Logout button action
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
    
    
    // Dismiss the Allert and form the segue
    func okDismissAlertAndPerformSegue(titleStr titleStr: String, messageStr: String, controller: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.Alert)
        let okDismiss: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: {
                action in self.checkIfLogged()
            })
        alert.addAction(okDismiss)
        controller.presentViewController(alert, animated: true, completion: {})
    }
    
    
    // Get the user data and extract the data
    func extractDataAndCreateUserDataStruct() {
        
    }
    
    
    // Load the Udacity User Data
    func loadUserData() {
        startSpin(spinText: OTMClient.ConstantsMessages.LOADING_DATA)
        
        OTMClient.sharedInstance().udacityPOSTGetUserData(otmTabBarController.udacityUserId){
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
                    self.extractDataAndCreateUserDataStruct()
                    self.populateLocationList()
                }
            })
        }

    }
    
    
    // Load data from Parse
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
    
    
    
    // Add view to show the spin
    func startSpin(spinText spinText: String) {
        spinner = ActivityIndicatorView(text: spinText)
        view.addSubview(spinner)
    }
    
    
    // Function that will populate the MKAnnotations and Locations to display in the map
    func populateLocationList() {
        let results: [AnyObject] = responseAsNSDictinory[OTMClient.ConstantsParse.RESULTS] as! [AnyObject]
        print("results : \(results)")
        print(responseAsNSDictinory!)
    }
    
    
    // Select Posting View
    @IBAction func pinAction(sender: AnyObject) {
        navigationController?.navigationBarHidden = false
        otmTabBarController.tabBar.hidden = true
        performSegueWithIdentifier("PostingViewSegue", sender: self)
        let postingView: PostingViewController = storyboard!.instantiateViewControllerWithIdentifier("PostingView") as! PostingViewController
        postingView.userLocation = self.userLocation
    }
    
    
    // Refresh data and map
    @IBAction func refreshAction(sender: AnyObject) {
        checkIfLogged()
    }
    
}
