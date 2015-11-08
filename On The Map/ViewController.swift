//
//  ViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 9/21/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import Parse
import MapKit

// I'm going to keep this name, because XCode still craw if compared with other IDEs to refactor code and many other things!
class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    var otmTabBarController: OTMTabBarController!
    var spinner: ActivityIndicatorView!
    var appDelegate: AppDelegate!

    
    //
    // Called when view has been loaded
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        otmTabBarController = tabBarController as! OTMTabBarController
        
        appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        subscribeToKeyboardNotifications()
    }
    
    
    //
    // Called when view will appear
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBarHidden = true
    }
    
    
    //
    // Called when view will disappear
    //
    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    
    
    // Keyboard notify notification center the keyboard will show
    func keyboardWillShow(notification: NSNotification) {
        if (view.frame.origin.y >= 0 &&
            (email.isFirstResponder() || password.isFirstResponder())) {
                view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    
    //
    // Keyboard notify notification center the keyboard will hide
    //
    func keyboardWillHide(notification: NSNotification) {
        if (view.frame.origin.y <= 0 && (email.isFirstResponder() || password.isFirstResponder())) {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    
    //
    // Delegate when user hit the soft key Done from keyboard, we collapse the keyboard
    //
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //
    // Get the keyboard hieght to move the to be hidden UITextView
    //
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height + 10
    }
    
    
    //
    // Subscribe methods keyboardWillShow and keyboardWillHide to the notification center
    //
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:" , name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:" , name:UIKeyboardWillHideNotification, object: nil)
    }
    
    
    //
    // Unsubscribe methods keyboardWillShow and keyboardWillHide from the notification center
    //
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    
    //
    //Calls this function when the tap is recognized.
    //
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    //
    // Login button
    //
    @IBAction func loginAction(sender: UIButton) {
        DismissKeyboard()        
        startSpin(spinText: OTMClient.ConstantsMessages.LOGIN_PROCESSING)
       
        loginButton.enabled = false
        signUpButton.enabled = false
        
        OTMClient.sharedInstance().udacityPOSTLogin(userName: email.text!, password: password.text!) {
            (success, errorString)  in
            
            var isSuccess: Bool = false
            if (success != nil) {
                // Convert the NSDictionary that is received as AnyObject to Dictionary
                let responseAsNSDictinory: Dictionary<String, AnyObject> = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if ((responseAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let messageToDialog = OTMClient.sharedInstance().parseErrorReturned(responseAsNSDictinory)
                    Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOGIN_FAILED, messageStr: messageToDialog, controller: self)
                } else {
                    let successResponse = OTMClient.sharedInstance().successLoginResponse(responseAsNSDictinory, otmTabBarController: self.otmTabBarController)
                    isSuccess = successResponse.isSuccess
                    self.otmTabBarController = successResponse.otmTabBarController
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.LOGIN_FAILED, messageStr: (errorString?.description)!, controller: self)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                // Dismiss modal
                self.spinner.hide()
                self.loginButton.enabled = true
                self.signUpButton.enabled = true
                
                // If success extracting data then call the TabBarController Map view
                if (isSuccess) {
                    self.otmTabBarController.udacityUserId = self.email.text!
                    self.loadUserData()
                }
            }
        }
    }
    
    
    //
    // Load the Udacity User Data
    //
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
            
            dispatch_async(dispatch_get_main_queue()) {
                // Dismiss modal
                self.spinner.hide()
                
                // If success extracting data then call the TabBarController Map view
                if (isSuccess) {
                    let tempEmptyMKPointAnnotation: MKPointAnnotation = MKPointAnnotation()
                    let utils: Utils = Utils()
                    self.otmTabBarController.localUserData = utils.createLocalUserData(userDataDictionary: responseLoadUserDataAsNSDictinory, objectId: OTMClient.ConstantsGeneral.EMPTY_STR, udacityKey: self.otmTabBarController.udacityKey, latDouble: 0, lonDouble: 0, pointInformation: tempEmptyMKPointAnnotation)
                    
                    self.navigationController?.navigationBarHidden = false
                    self.otmTabBarController.tabBar.hidden = false
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
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
    // Signup link button
    //
    @IBAction func signUpAction(sender: UIButton) {
        DismissKeyboard()
    }
}

