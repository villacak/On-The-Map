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
    var mapPoints: [MKAnnotation]!
    var userLocation: CLLocationCoordinate2D!
    var otmTabBarController: OTMTabBarController!
    var spinner: ActivityIndicatorView!
    var userData: UserData?
    
    var latDouble: Double = 0
    var lonDouble: Double = 0
    
    
    // View Did Load - Runs this function
    override func viewDidLoad() {
        super.viewDidLoad()
        otmTabBarController = tabBarController as! OTMTabBarController
        
        mapView.mapType = MKMapType.Standard
//        mapView.removeAnnotation(mapView.annotations)
        
        // Acquire user geo position
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
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
            } else {
                loadData(numberToLoad: paginationSize, cacheToPaginate: initialCache, orderListBy: OTMServicesNameEnum.updateAt)
            }
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
        
        latDouble = currentLocation.coordinate.latitude
        lonDouble = currentLocation.coordinate.longitude
        
//        print("Locations: Latitude = \(latDouble), Longitude = \(lonDouble), Current Location Lat/Lon= \(currentLocation.coordinate.latitude) \\ \(currentLocation.coordinate.longitude)")
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
    
    
    // Dismiss the Allert and form the segue
    func okDismissAlertAndPerformSegue(titleStr titleStr: String, messageStr: String, controller: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.Alert)
        let okDismiss: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: {
                action in self.checkIfLogged()
            })
        alert.addAction(okDismiss)
        controller.presentViewController(alert, animated: true, completion: {})
    }
    
    
    
    // Load the Udacity User Data
    func loadUserData() {
        startSpin(spinText: OTMClient.ConstantsMessages.LOADING_DATA)
        
        OTMClient.sharedInstance().udacityPOSTGetUserData(otmTabBarController.udacityUserId){
            (success, errorString)  in
            var isSuccess: Bool = false
            var responseLoadUserDataAsNSDictinory: Dictionary<String, AnyObject>!
            if (success != nil) {
                responseLoadUserDataAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if ((responseLoadUserDataAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let message: String = OTMClient.sharedInstance().parseErrorReturned(responseLoadUserDataAsNSDictinory)
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
//                    print("Load UserData")
//                    print(responseLoadUserDataAsNSDictinory!)
                    self.populateUserData(allUserData: responseLoadUserDataAsNSDictinory)
                    self.loadData(numberToLoad: self.paginationSize, cacheToPaginate: self.initialCache, orderListBy: OTMServicesNameEnum.updateAt)
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
            var responseLoadMapDataAsNSDictinory: Dictionary<String, AnyObject>!
            if (success != nil) {
                responseLoadMapDataAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if ((responseLoadMapDataAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let message: String = OTMClient.sharedInstance().parseErrorReturned(responseLoadMapDataAsNSDictinory)
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
                    self.populateLocationList(mapData: responseLoadMapDataAsNSDictinory)
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
    func populateUserData(allUserData allUserData: Dictionary<String, AnyObject>) {
        let fullUserData: Dictionary<String, AnyObject> = allUserData[OTMClient.ConstantsUdacity.USER] as! Dictionary<String, AnyObject>
        
        let firstName: String = fullUserData[OTMClient.ConstantsData.firstNameUD] as! String
        let lastName:String = fullUserData[OTMClient.ConstantsData.lastNameUD] as! String
        if (userLocation != nil) {
            latDouble = userLocation.latitude as Double
            lonDouble = userLocation.longitude as Double
        }
        
        
        let userData: UserData = UserData(objectId: OTMClient.ConstantsGeneral.EMPTY_STR, uniqueKey: otmTabBarController.udacityKey, firstName: firstName, lastName: lastName, mapString: OTMClient.ConstantsGeneral.EMPTY_STR, mediaUrl: OTMClient.ConstantsGeneral.EMPTY_STR, latitude: latDouble, longitude: lonDouble, createdAt: NSDate(), updatedAt: NSDate())
        otmTabBarController.userDataDic[otmTabBarController.udacityKey] = userData
        
        print(userData)
    }
    
    
    func populateLocationList(mapData mapData: Dictionary<String, AnyObject>) {
        let results: [AnyObject] = mapData[OTMClient.ConstantsParse.RESULTS] as! [AnyObject]
        print(results)
        
//        for (key, value) in results {
//            print("item key: \(key), value: \(value)")
//            if (key == otmTabBarController.udacityKey) {
//                print("Key found -->")
//                print(value)
////                userLocation = CLLocationCoordinate2D(latitude: <#T##CLLocationDegrees#>, longitude: <#T##CLLocationDegrees#>)
//            }
//        }
        

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
