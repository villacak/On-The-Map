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
    
    let paginationSize: String = "100"
    let initialCache: String = "400"
    let reusableId: String = "usersInfo"
    
    var locationManager: CLLocationManager!
    var locationList: [MKPointAnnotation]!
    var mapPoints: [MKAnnotation]!
    var userLocation: CLLocationCoordinate2D!
    
    var otmTabBarController: OTMTabBarController!
    var spinner: ActivityIndicatorView!
    var userData: UserData?
    var appDelegate: AppDelegate!
    
    var latDouble: Double = 0
    var lonDouble: Double = 0
    
    
    // View Did Load - Runs this function
    override func viewDidLoad() {
        super.viewDidLoad()
        otmTabBarController = tabBarController as! OTMTabBarController
        appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
        // Set the locationManager, if by some problem we create a new object
        if let tempLocation = appDelegate.locationManager {
            locationManager = tempLocation
        } else {
            locationManager = CLLocationManager()
            appDelegate.locationManager = locationManager
        }
        
        mapView.mapType = MKMapType.Standard
        
        // Acquire user geo position
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
        }

    }
    
    
    // Calles just before view will appear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        otmTabBarController.tabBar.hidden = false

        // Add the observer
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "willEnterForegound",
            name: UIApplicationWillEnterForegroundNotification,
            object: nil)

        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
        checkIfLogged()
    }
    
    
    // Remove the observer
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIApplicationWillEnterForegroundNotification,
            object: nil)
    }
    
    
    
    func willEnterForegound() {
        locationManager.startUpdatingLocation()
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
        print("Current Location Lat/Lon= \(userLocation.latitude) \\ \(userLocation.longitude)")
    }
    
    
    // Add view to show the spin
    func startSpin(spinText spinText: String) {
        spinner = ActivityIndicatorView(text: spinText)
        view.addSubview(spinner)
    }
    
    
    
    // Location Manager called when error occur when loading locations
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let message: String = OTMClient.ConstantsMessages.ERROR_UPDATING_LOCATION + error.localizedDescription
        Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOADING_DATA_FAILED, messageStr: message, controller: self)
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
 
    
    // Function that will populate the MKAnnotations and Locations to display in the map
    func populateUserData(allUserData allUserData: Dictionary<String, AnyObject>) {
        let fullUserData: Dictionary<String, AnyObject> = allUserData[OTMClient.ConstantsUdacity.USER] as! Dictionary<String, AnyObject>
        
        let firstName: String = fullUserData[OTMClient.ConstantsData.firstNameUD] as! String
        let lastName:String = fullUserData[OTMClient.ConstantsData.lastNameUD] as! String
        if (userLocation != nil) {
            latDouble = userLocation.latitude as Double
            lonDouble = userLocation.longitude as Double
        }
        
        let fullName: String = "\(firstName) \(lastName)"
        let tempMKPointAnnotation: MKPointAnnotation = createMkPointAnnotation(fullName: fullName, urlStr: OTMClient.ConstantsGeneral.EMPTY_STR, latitude: latDouble, longitude: lonDouble)
        
        let userData: UserData = UserData(objectId: OTMClient.ConstantsGeneral.EMPTY_STR, uniqueKey: otmTabBarController.udacityKey, firstName: firstName, lastName: lastName, mapString: OTMClient.ConstantsGeneral.EMPTY_STR, mediaUrl: OTMClient.ConstantsGeneral.EMPTY_STR, latitude: latDouble, longitude: lonDouble, createdAt: NSDate(), updatedAt: NSDate(), userLocation: tempMKPointAnnotation)
        otmTabBarController.userDataDic[otmTabBarController.udacityKey] = userData
        
        print(userData)
    }
    
    
    // Populate the pins from the list into the map
    func populateLocationList(mapData mapData: Dictionary<String, AnyObject>) {
        let results: [AnyObject] = mapData[OTMClient.ConstantsParse.RESULTS] as! [AnyObject]
        // If count is zero, we try to get a pre-populated data from the userDataPic
        if results.count == 0 {
            let tempUserData: UserData = otmTabBarController.userDataDic[otmTabBarController.udacityKey]!
            if let tempMKPointAnnotation = tempUserData.userLocation {
                mapView.addAnnotation(tempMKPointAnnotation)
            }
        } else {
            // Populate the map with the list
            for userDataJson in results {
                print("item value: \(userDataJson)")
//                if (key == otmTabBarController.udacityKey) {
//                    print("Key found -->")
//                    print(value)
//                }
            }
        }
    }
    
    
    //
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(reusableId) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusableId)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIView
        }
        return view
    }
    
    
    
    // Create the Point Annotation and return it
    func createMkPointAnnotation(fullName fullName: String, urlStr: String, latitude: Double, longitude: Double) -> MKPointAnnotation {
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let objectAnnotation: MKPointAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = fullName
        objectAnnotation.subtitle = urlStr
//        let rightMapLabelButton: UIButton = UIButton(type: UIButtonTypeDetailDisclosure)
    
//        objectAnnotation.rightCalloutAccessoryView = rightButton;

        return objectAnnotation
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
        mapView.removeAnnotations(mapView.annotations)
        checkIfLogged()
    }
    
}
