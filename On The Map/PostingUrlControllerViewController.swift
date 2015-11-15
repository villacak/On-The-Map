//
//  PostingUrlControllerViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 11/13/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import MapKit

class PostingUrlControllerViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var urlMapView: MKMapView!
    @IBOutlet weak var mediaURL: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var otmTabBarController: OTMTabBarController!
    var spinner: ActivityIndicatorView!
    var appDelegate: AppDelegate!
    
    var latitudeReceived: Double!
    var longitudeReceived: Double!
    
    var addressString: String!
    var mediaUrlString: String!
    
    var isCreate: Bool = false
    
    let reusableId: String = "urlInfo"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController!.navigationBar.barTintColor = UIColor.clearColor()
//        cancelButton.tintColor = UIColor.clearColor()
       
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        otmTabBarController = tabBarController as! OTMTabBarController
        appDelegate = otmTabBarController.appDelegate
        
        urlMapView.mapType = MKMapType.Standard
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if let tempAddress = addressString {
            addressLabel.text = tempAddress
        }
        
        if let tempUrl = mediaUrlString {
            mediaURL.text = tempUrl
        }
        
        // Add the annotation to the map
        let annotationToMap: MKPointAnnotation = MKPointAnnotation()
        annotationToMap.coordinate.latitude = latitudeReceived
        annotationToMap.coordinate.longitude = longitudeReceived
        urlMapView.addAnnotation(annotationToMap)
        
        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitudeReceived, longitudeReceived)
        urlMapView.setCenterCoordinate(userLocation, animated: true)

        let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation, 500, 500)
        urlMapView.setRegion(viewRegion, animated: false)
        
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        otmTabBarController.appDelegate = appDelegate
    }
    
    
    //
    // Delegate when user hit the soft key Done from keyboard, we collapse the keyboard
    //
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //
    //Calls this function when the tap is recognized.
    //
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.navigationBarHidden = false
    }
    
    
    //
    // Post user location for the very first time, then once we have the objectId we just use updateData()
    //
    func putData() {
        let caller: OTMServiceCaller = OTMServiceCaller()
        caller.putData(domainUtils: appDelegate.domainUtils, stringPlace: addressLabel.text!, mediaURL: mediaURL.text!, latitude: latitudeReceived, longitude: longitudeReceived) { (result, errorString)  in
            var isSuccess = false
            if let tempError = errorString {
                Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOGOUT_FAILED, messageStr: tempError, controller: self)
            } else {
                isSuccess = true
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                // Dismiss modal
                self.spinner.hide()
                
                // If success extracting data then call the TabBarController Map view
                if (isSuccess) {
                    self.appDelegate.domainUtils = result
                    self.updateDataAndDismissView()
                }
            }
        }
    }
    
    
    //
    // Function called always that the local user already has a objectId form parse
    //
    //
    // Post user location for the very first time, then once we have the objectId we just use updateData()
    //
    func updateData() {
        let caller: OTMServiceCaller = OTMServiceCaller()
        caller.updateData(domainUtils: appDelegate.domainUtils, stringPlace: addressLabel.text!, mediaURL: mediaURL.text!, latitude: latitudeReceived, longitude: longitudeReceived) { (result, errorString)  in
            var isSuccess = false
            if let tempError = errorString {
                Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOGOUT_FAILED, messageStr: tempError, controller: self)
            } else {
                isSuccess = true
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                // Dismiss modal
                self.spinner.hide()
                
                // If success extracting data then call the TabBarController Map view
                if (isSuccess) {
                    self.appDelegate.domainUtils = result
                    self.updateDataAndDismissView()
                }
            }
        }
    }
    
    
    //
    // Add view to show the spin
    //
    func startSpin(spinText spinText: String) {
        spinner = ActivityIndicatorView(text: spinText)
        view.addSubview(spinner)
    }
    
    //
    // Load data from Parse
    //
    func loadData(numberToLoad numberToLoad: String, cacheToPaginate: String, orderListBy: OTMServicesNameEnum) {
        startSpin(spinText: OTMClient.ConstantsMessages.LOADING_DATA)
        
        let caller: OTMServiceCaller = OTMServiceCaller()
        caller.loadData(numberToLoad: numberToLoad, cacheToPaginate: cacheToPaginate, orderListBy: orderListBy, domainUtils: appDelegate.domainUtils) { (result, error) in
            
            var isSuccess = false
            if let tempError = error {
                Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOADING_DATA_FAILED, messageStr: tempError, controller: self)
            } else {
                isSuccess = true
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                // Dismiss modal
                self.spinner.hide()
                
                if (isSuccess) {
                    self.otmTabBarController.tabBar.hidden = false
                    self.appDelegate.domainUtils = result
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    self.navigationController?.navigationBarHidden = false
                }
            }
        }
    }

    
    //
    // Dismiss view returning
    //
    func updateDataAndDismissView() {
        appDelegate.domainUtils.userDataDic.removeAll()
        appDelegate.domainUtils.mapPoints.removeAll()
        loadData(numberToLoad: OTMClient.ConstantsParse.PAGINATION, cacheToPaginate: OTMClient.ConstantsGeneral.EMPTY_STR, orderListBy: OTMServicesNameEnum.updatedAtInverted)
    }
    
    
    
    
    
    //
    // Submit Action
    //
    @IBAction func submitAction(sender: AnyObject) {
        submitHelper()
    }
    
    
    //
    // Submit helper
    //
    func submitHelper() {
        
        if mediaURL.text!.characters.count > 0 {
            spinner = ActivityIndicatorView(text: "Saving...")
            view.addSubview(spinner)
            if appDelegate.domainUtils.localUserData.objectId != OTMClient.ConstantsGeneral.EMPTY_STR {
                isCreate = false
            } else {
                isCreate = true
            }
            
            if (isCreate) {
                putData()
            } else {
                updateData()
            }
        } else {
            Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.NO_URL_DEFINED, messageStr: "URL Cannot be null.", controller: self)
        }
        

    }
    
    //
    // Location Manager called when error occur when loading locations
    //
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let message: String = OTMClient.ConstantsMessages.ERROR_UPDATING_LOCATION + error.localizedDescription
        Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOADING_DATA_FAILED, messageStr: message, controller: self)
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

}
