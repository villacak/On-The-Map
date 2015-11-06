//
//  MapViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/3/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//


// Comments regarding calling the request service with completion handler.
// Due the completion handler and we need to run certain tasks in the main
// trhead. The code becomes very coupled too quickly.
// My plan was to have logout refresh and PostingView actions in one class
// however it simple doesn't work as in the end I need run my calls from
// the main thread and due the result take some time to return and make calls
// within main thread when the result has returned, there is quite few we can do
// to decouple those functions calls that trigger those request calls.
// If I did have a way to get the response and then return to thos class to then
// make those calls within the main thread it woud work. I hope I made myself undertood.
// Due that the code doesn't look really nice and we duplicate very similar functions
//
import UIKit
import Parse
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    let paginationSize: String = "100"
    let initialCache: String  = OTMClient.ConstantsGeneral.EMPTY_STR
    let reusableId: String = "usersInfo"
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocationCoordinate2D!
    
    var otmTabBarController: OTMTabBarController!
    var spinner: ActivityIndicatorView!
    
    
    var latDouble: Double = 0
    var lonDouble: Double = 0
    
    
    
    
    //
    // View Did Load - Runs this function
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        otmTabBarController = tabBarController as! OTMTabBarController
        otmTabBarController.appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
    }
    
    
    //
    // Calles just before view will appear
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Set the locationManager, if by some problem we create a new object
        if let tempLocation = otmTabBarController.appDelegate.locationManager {
            locationManager = tempLocation
        } else {
            locationManager = CLLocationManager()
            otmTabBarController.appDelegate.locationManager = locationManager
        }
        
        // Acquire user geo position
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
        }
        
        otmTabBarController.tabBar.hidden = false
        
        mapView.mapType = MKMapType.Standard
        
        
        // Add the observer
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "willEnterForegound",
            name: UIApplicationWillEnterForegroundNotification,
            object: nil)
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
//            locationManager.startUpdatingLocation()
        }
        checkIfLogged()
    }
    
    
    //
    // Remove the observer just before the view disapear
    //
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIApplicationWillEnterForegroundNotification,
            object: nil)
    }
    
    
    //
    // Function called when adding the observer
    //
    func willEnterForegound() {
        locationManager.startUpdatingLocation()
    }
    
    
    //
    // Check if the user have already logged or not, if logged load data, if not redirect to the login page
    //
    func checkIfLogged() {
        if otmTabBarController.udacityKey == OTMClient.ConstantsGeneral.EMPTY_STR {
            otmTabBarController.tabBar.hidden = true
            performSegueWithIdentifier("LoginSegue", sender: self)
            self.storyboard!.instantiateViewControllerWithIdentifier("OTMFBAuthViewController")
        } else {
            // We will always repopulate the map points to have always 'fresh' data
            removeAnnotations()
            loadData(numberToLoad: paginationSize, cacheToPaginate: initialCache, orderListBy: OTMServicesNameEnum.updateAt)
        }
    }
    
    
    //
    // Called whe nmap view has finished to load
    //
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    
    //
    // Called when mapview will start to load
    //
    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    
    //
    // Location Manager called when locations have been updated
    //
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = manager.location?.coordinate
    }
    
    
    //
    // Add view to show the spin
    //
    func startSpin(spinText spinText: String) {
        spinner = ActivityIndicatorView(text: spinText)
        view.tag = 100
        view.addSubview(spinner)
    }
    
    
    //
    // Remove subView from spin
    //
    func dismissSpin() {
        spinner.hide()
        //        if let viewWithTag = self.view.viewWithTag(100) {
        //            viewWithTag.removeFromSuperview()
        //        }
    }
    
    
    //
    // Location Manager called when error occur when loading locations
    //
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let message: String = OTMClient.ConstantsMessages.ERROR_UPDATING_LOCATION + error.localizedDescription
        Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOADING_DATA_FAILED, messageStr: message, controller: self)
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
    // Load data from Parse
    //
    func loadData(numberToLoad numberToLoad: String, cacheToPaginate: String, orderListBy: OTMServicesNameEnum) {
        startSpin(spinText: OTMClient.ConstantsMessages.LOADING_DATA)
        
//        dispatch_async(dispatch_get_global_queue(priority, 0)) {
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
                
                dispatch_async(dispatch_get_main_queue()) {
                    // Dismiss modal
                    self.dismissSpin()
                    
                    // If success extracting data then call the TabBarController Map view
                    if (isSuccess) {
                        let utils: Utils = Utils()
                        self.otmTabBarController.mapPoints = utils.populateLocationList(mapData: responseLoadMapDataAsNSDictinory)
                        self.mapView.addAnnotations(self.otmTabBarController.mapPoints)
                        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                    }
                }
            }
//        }
    }
    
    
    //
    // Check for annotations for display
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
    
    
    //
    // Call the url into Safari if it exist.
    //
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if view.annotation!.subtitle! != OTMClient.ConstantsGeneral.EMPTY_STR {
                app.openURL((NSURL(string: view.annotation!.subtitle!!)!))
            } else {
                Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.ERROR_TITLE, messageStr: OTMClient.ConstantsMessages.NO_URL_DEFINED, controller: self)
            }
        }
    }
    
    
    
    //
    // Logout button action
    //
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
            
            dispatch_async(dispatch_get_main_queue()) {
                // Dismiss modal
                self.dismissSpin()
                
                // If success extracting data then call the TabBarController Map view
                if (isSuccess) {
                    self.otmTabBarController.udacitySessionId = OTMClient.ConstantsGeneral.EMPTY_STR
                    self.otmTabBarController.udacityKey = OTMClient.ConstantsGeneral.EMPTY_STR
                    self.otmTabBarController.loggedOnUdacity = false
                    self.navigationController?.navigationBarHidden = true
                    self.okDismissAlertAndPerformSegue(titleStr: OTMClient.ConstantsMessages.LOGOUT_SUCCESS, messageStr: OTMClient.ConstantsMessages.LOGOUT_SUCCESS_MESSAGE, controller: self)
                }
            }
        }
    }
    
    
    //
    // Remove all annotations from mapview
    //
    func removeAnnotations() {
        if let tempLocations: [MKAnnotation] = mapView.annotations {
            mapView.removeAnnotations(tempLocations)
        }
    }
    
    
    //
    // Select Posting View
    //
    @IBAction func pinAction(sender: AnyObject) {
        navigationController?.navigationBarHidden = false
        otmTabBarController.tabBar.hidden = true
        performSegueWithIdentifier("PostingViewSegue", sender: self)
        let postingView: PostingViewController = storyboard!.instantiateViewControllerWithIdentifier("PostingView") as! PostingViewController
        postingView.userLocation = self.userLocation
    }
    
    
    //
    // Refresh data and map
    //
    @IBAction func refreshAction(sender: AnyObject) {
        if (mapView.annotations.count > 0) {
            otmTabBarController.mapPoints.removeAll()
            removeAnnotations()
        }
        checkIfLogged()
    }
    
}
