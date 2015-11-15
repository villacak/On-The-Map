//
//  PostingViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/18/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

//import Foundation
import UIKit
import Parse
import MapKit


class PostingViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var textWithData: UITextField!
    
    var otmTabBarController: OTMTabBarController!
    var spinner: ActivityIndicatorView!
    var locationManager: CLLocationManager!
    var userLocation: CLLocationCoordinate2D!
    var latFromAddress: Double = 0
    var lonFromAddress: Double = 0
    var appDelegate: AppDelegate!

    
    //
    // Called just after view did load
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        otmTabBarController = tabBarController as! OTMTabBarController
        appDelegate = otmTabBarController.appDelegate
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        otmTabBarController.appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
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
        
        if appDelegate.domainUtils.localUserData.mapString != OTMClient.ConstantsGeneral.EMPTY_STR {
            textWithData.text = appDelegate.domainUtils.localUserData.mapString
        }
    }
    
    
    //
    // Called when the view will appear
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    
    //
    // Set the delegate and values back
    //
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

    
    
    //
    // Function that do the Address to Latitude and Longitude
    //
    func getLatAndLongFromAddress(address address:String) {
        let geocoder = CLGeocoder()
        var isSuccess = false
        
        geocoder.geocodeAddressString(address) {(placemarks, error) -> Void in
            if((error) != nil){
                Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.ERROR_TITLE, messageStr: (error?.description)!, controller: self)
            }
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                self.latFromAddress = coordinates.latitude
                self.lonFromAddress = coordinates.longitude
                isSuccess = true
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                // Dismiss modal
                self.spinner.hide()
               
                // If success extracting data then call the TabBarController Map view
                if (isSuccess) {
                    self.navigationController?.navigationBarHidden = false
                    self.otmTabBarController.tabBar.hidden = true
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PostingURLView") as! PostingUrlControllerViewController
                    controller.addressString = self.textWithData.text!
                    controller.mediaUrlString = self.appDelegate.domainUtils.localUserData.mediaURL
                    controller.latitudeReceived = self.latFromAddress
                    controller.longitudeReceived = self.lonFromAddress
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            })
        }
    }

    
    //
    // Add the new text and URL to the location
    //
    @IBAction func findOnTheMapAction(sender: AnyObject) {
        spinner = ActivityIndicatorView(text: "Saving...")
        view.addSubview(spinner)
        getLatAndLongFromAddress(address: textWithData.text!)
    }
    
    
    //
    // Cancel Button action
    //
    @IBAction func cancelAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.navigationBarHidden = false

    }
    
}
