//
//  PostingViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/18/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import MapKit

class PostingViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var textWithData: UITextField!
    @IBOutlet weak var personalUrl: UITextField!
    
    var otmTabBarController: OTMTabBarController!
    var spinner: ActivityIndicatorView!
    
    var userData: UserData?
    var userLocation: CLLocationCoordinate2D!
    var udacityKey: String!
    var latFromAddress: Double = 0
    var lonFromAddress: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otmTabBarController = tabBarController as! OTMTabBarController
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        subscribeToKeyboardNotifications()
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        udacityKey = otmTabBarController.udacityKey
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    
    // Keyboard notify notification center the keyboard will show
    func keyboardWillShow(notification: NSNotification) {
//        if (view.frame.origin.y >= 0 &&
//            personalUrl.isFirstResponder() ) {
//                view.frame.origin.y -= getKeyboardHeight(notification)
//        }
    }
    
    
    // Keyboard notify notification center the keyboard will hide
    func keyboardWillHide(notification: NSNotification) {
//        if (view.frame.origin.y <= 0 && personalUrl.isFirstResponder()) {
//            view.frame.origin.y += getKeyboardHeight(notification)
//        }
    }
    
    
    // Delegate when user hit the soft key Done from keyboard, we collapse the keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // Get the keyboard hieght to move the to be hidden UITextView
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height + 10
    }
    
    
    /*
    * Subscribe methods keyboardWillShow and keyboardWillHide to the notification center
    */
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:" , name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:" , name:UIKeyboardWillHideNotification, object: nil)
    }
    
    
    /*
    * Unsubscribe methods keyboardWillShow and keyboardWillHide from the notification center
    */
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    // Add the new text and URL to the location
    @IBAction func findOnTheMapAction(sender: AnyObject) {
        spinner = ActivityIndicatorView(text: "Saving...")
        view.addSubview(spinner)
        
        getLatAndLongFromAddress(address: textWithData.text!)

        assembleUserData();
        var responseAsNSDictinory: Dictionary<String, AnyObject>!
        
        OTMClient.sharedInstance().putPOSTStudentLocation(userData: userData!){
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
                    self.otmTabBarController.userDataDic[self.udacityKey] = self.userData;
                    self.dismissView()
                }
            })
        }
    }
    
    
    
    func getLatAndLongFromAddress(address address:String) {
        let geocoder = CLGeocoder()
       
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.ERROR_TITLE, messageStr: (error?.description)!, controller: self)
            }
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
                self.latFromAddress = coordinates.latitude
                self.lonFromAddress = coordinates.longitude
            }
            
        })
    }
    
    
    // Here we set all values to the UserData struct
    func assembleUserData() {
        if let userDataTemp = otmTabBarController.userDataDic[otmTabBarController.udacityKey] {
            userData = UserData(objectId: userDataTemp.objectId, uniqueKey: userDataTemp.uniqueKey, firstName: userDataTemp.firstName, lastName: userDataTemp.lastName, mapString: textWithData.text, mediaUrl: personalUrl.text, latitude: userLocation.latitude, longitude: userLocation.longitude, createdAt: userDataTemp.createdAt, updatedAt: NSDate(), userLocation: userDataTemp.userLocation)
        }
    }
    
    
    // Dismiss view returning
    func dismissView() {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    // Cancel Button action
    @IBAction func cancelAction(sender: AnyObject) {
        dismissView()
    }
    
}
