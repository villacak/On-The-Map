//
//  ViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 9/21/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import Parse

// I'm going to keep this name, because XCode still craw if compared with other IDEs to refactor code and many other things!
class ViewController: ViewControllerWithKeyboardControl, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signinFacebookButton: UIButton!
    
    var activityIndicatorView: ActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otmTabBarController = tabBarController as! OTMTabBarController
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        subscribeToKeyboardNotifications()
        
        // Config my custom activityIndicator
        activityIndicatorView = ActivityIndicatorView(title: OTMClient.ConstantsMessages.LOGIN_PROCESSING, center: self.view.center)
        view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        activityIndicatorView.hideActivityIndicator()
    
        
        //        let testObject = PFObject(className: "TestObject")
        //        testObject["foo"] = "bar"
        //        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        //            print("Object has been saved.")
        //        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBarHidden = true
        
        // I'm hidding the Facebook button as I don't have account on it and never had plans to have it.
        // I think Udacity should have their own API for the same purpose as it's just learning.
        signinFacebookButton.hidden = true
        signinFacebookButton.enabled = false
    }
    
   
    
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
    
    
    
    // Keyboard notify notification center the keyboard will hide
    func keyboardWillHide(notification: NSNotification) {
        if (view.frame.origin.y <= 0 && (email.isFirstResponder() || password.isFirstResponder())) {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
   
    
    @IBAction func loginAction(sender: UIButton) {
        DismissKeyboard()
        navigationController?.navigationBarHidden = false
        otmTabBarController.udacityKey = "test"
        
        navigationController?.popViewControllerAnimated(true)
        
//        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarControllerSB") as! OTMTabBarController
//        self.presentViewController(controller, animated: true, completion: nil)
       
      
//        activityIndicatorView.showActivityIndicator()
//        activityIndicatorView.startAnimating()
//        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
//        
//        OTMClient.sharedInstance().udacityFacebookPOSTLogin(userName: email.text!, password: password.text!, facebookToken: nil, isUdacity: true) {
//            (success, errorString)  in
//            if (success != nil) {
//                // Convert the NSDictionary that is received as AnyObject to Dictionary
//                let responseAsNSDictinory: Dictionary<String, AnyObject> = (success as! NSDictionary) as! Dictionary<String, AnyObject>
//                
//                // Dismiss modal
//                self.activityIndicatorView.hideActivityIndicator()
//                self.activityIndicatorView.stopAnimating()
//                UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                
//                // Check if the response contains any error or not
//                if ((responseAsNSDictinory.indexForKey("error")) != nil) {
//                    self.parseErrorReturned(responseAsNSDictinory)
//                } else {
//                    let isSuccess = self.successLogin(responseAsNSDictinory)
//                    
//                    // If success extracting data then call the TabBarController Map view
//                    if (isSuccess) {
//                        navigationController?.popViewControllerAnimated(true)
//                    }
//                }
//            } else {
//                // Dismiss modal
//                self.activityIndicatorView.hideActivityIndicator()
//                self.activityIndicatorView.stopAnimating()
//                UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                
//                // If success returns nil then it's necessary display an alert to the user
//                Dialog().okDismissAlert(titleStr: "Login Failed", messageStr: (errorString?.description)!, controller: self)
//            }
//        }
    }
    
    
    
    @IBAction func signUpAction(sender: UIButton) {
        DismissKeyboard()
    }
    
    
    
    // Facebook buttom is disabled
    @IBAction func signInFacebookButton(sender: UIButton) {
        DismissKeyboard()
    }
    
    
    
    // Parse error returned
    func parseErrorReturned(responseDictionary: Dictionary<String, AnyObject>) {
        let statusCode = responseDictionary[OTMClient.ConstantsUdacity
            .STATUS] as! String
        let errorMessage = responseDictionary[OTMClient.ConstantsUdacity.ERROR] as! String
        let messageString: String = "\(statusCode), \(errorMessage)"
        
        // If success returns with an error message we need to show it to the user as an alert
        Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.INVALID_LOGIN, messageStr: messageString , controller: self)
    }
    
    
    
    // Success login helper,
    // Stores key and id in AppDelegate to use for sub-sequent requests
    func successLogin(responseDictionary: Dictionary<String, AnyObject>)-> Bool {
        var isSuccess:Bool = false
        otmTabBarController.loggedOnUdacity = true
        let account: Dictionary<String, AnyObject> = responseDictionary[OTMClient.ConstantsUdacity.ACCOUNT] as! Dictionary<String, AnyObject>
        
        otmTabBarController.udacityKey = account[OTMClient.ConstantsUdacity.ACCOUNT_KEY] as! String

        let session: Dictionary<String, AnyObject> = responseDictionary[OTMClient.ConstantsUdacity.SESSION] as! Dictionary<String, AnyObject>

        otmTabBarController.udacitySessionId = session[OTMClient.ConstantsUdacity.SESSION_ID] as! String

        if (self.otmTabBarController.udacityKey == OTMClient.ConstantsGeneral.EMPTY_STR && self.otmTabBarController.udacitySessionId == OTMClient.ConstantsGeneral.EMPTY_STR) {
            isSuccess = true
        }
        return isSuccess
    }
    
}

