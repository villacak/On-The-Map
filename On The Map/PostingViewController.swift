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
    @IBOutlet weak var personalUrl: UITextField!
    
    var otmTabBarController: OTMTabBarController!
    var spinner: ActivityIndicatorView!
    var locationManager: CLLocationManager!
    var userLocation: CLLocationCoordinate2D!
    var latFromAddress: Double = 0
    var lonFromAddress: Double = 0
    var isCreate: Bool = false
    
    //
    // Called just after view did load
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        otmTabBarController = tabBarController as! OTMTabBarController
        
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

        
    }
    
    
    //
    // Called when the view will appear
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
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
    // Post user location for the very first time, then once we have the objectId we just use updateData()
    //
    func putData() {
        var responseAsNSDictinory: Dictionary<String, AnyObject>!
        OTMClient.sharedInstance().putPOSTStudentLocation(userData: otmTabBarController.localUserData!){
            (success, errorString)  in
            var isSuccess: Bool = false
            if (success != nil) {
                responseAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if ((responseAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let message: String = OTMClient.sharedInstance().parseErrorReturned(responseAsNSDictinory)
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
                    self.addPUTResponseToUserData(response: responseAsNSDictinory)
                    self.dismissView()
                }
            })
        }
    }
  
    
    //
    // Function called always that the local user already has a objectId form parse
    //
    //
    // Post user location for the very first time, then once we have the objectId we just use updateData()
    //
    func updateData() {
        var responseAsNSDictinory: Dictionary<String, AnyObject>!
        OTMClient.sharedInstance().updatingPUTStudentLocation(userData: otmTabBarController.localUserData){
            (success, errorString)  in
            var isSuccess: Bool = false
            if (success != nil) {
                responseAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if ((responseAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let message: String = OTMClient.sharedInstance().parseErrorReturned(responseAsNSDictinory)
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
                    self.addPUTResponseToUserData(response: responseAsNSDictinory)
                    self.dismissView()
                }
            })
        }
    }

    
    
    //
    // Function to help make the code cleaner, it assembly a new UserData struct and set it to the 
    // parent class OTMTabBarController
    //
    func addPUTResponseToUserData(response response: Dictionary<String, AnyObject>) {
        let utils: Utils = Utils()
        let putUserResponse = utils.extractDataFromPUTUserResponse(putDataResponse: response)
        let tempUD: UserData = self.otmTabBarController.localUserData
        let tempFullName: String = "\(tempUD.firstName) \(tempUD.lastName)"
        let tempAnnotation: MKPointAnnotation = utils.createMkPointAnnotation(fullName: tempFullName, urlStr: self.personalUrl.text!, latitude: self.latFromAddress, longitude: self.lonFromAddress)
        
        self.otmTabBarController.localUserData = UserData(objectId: putUserResponse.tempObjectId, uniqueKey: tempUD.uniqueKey!, firstName: tempUD.firstName!, lastName: tempUD.lastName, mapString: self.textWithData.text!, mediaUrl: self.personalUrl.text!, latitude: self.latFromAddress, longitude: self.lonFromAddress, createdAt: putUserResponse.tempCreatedAt, updatedAt: putUserResponse.tempCreatedAt, userLocation: tempAnnotation)
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
                    print(self.personalUrl.text!)
                    
                    let utils: Utils = Utils()
                    self.otmTabBarController.localUserData = utils.addLocationToLocalUserData(userData: self.otmTabBarController.localUserData, stringPlace: self.textWithData.text!, mediaUrl: self.personalUrl.text!, latitude: self.latFromAddress, longitude: self.lonFromAddress)
                    if (self.isCreate) {
                        self.putData()
                    } else {
                        self.updateData()
                    }
                }
            })
        }
    }
    
    
    
    //
    // Dismiss view returning
    //
    func dismissView() {
        dispatch_async(dispatch_get_main_queue(), {
            // Dismiss modal
            self.navigationController?.popViewControllerAnimated(true)
            self.navigationController?.navigationBarHidden = false
        })
    }

    
    //
    // Add the new text and URL to the location
    //
    @IBAction func findOnTheMapAction(sender: AnyObject) {
        spinner = ActivityIndicatorView(text: "Saving...")
        view.addSubview(spinner)
        if otmTabBarController.localUserData.objectId != OTMClient.ConstantsGeneral.EMPTY_STR {
            isCreate = false
        } else {
            isCreate = true
        }
        
        getLatAndLongFromAddress(address: textWithData.text!)
    }
    
    
    //
    // Cancel Button action
    //
    @IBAction func cancelAction(sender: AnyObject) {
        dismissView()
    }
    
}
