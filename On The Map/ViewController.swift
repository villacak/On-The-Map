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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        subscribeToKeyboardNotifications()
        
        // I'm hidding the Facebook button as I don't have account on it and never had plans to have it.
        // I have my own reasons to don't want my name in their savers.
        // I think Udacity should have their own API for the same purpose as it's just learning.
        signinFacebookButton.hidden = true
        signinFacebookButton.enabled = false
        
        //        let testObject = PFObject(className: "TestObject")
        //        testObject["foo"] = "bar"
        //        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        //            print("Object has been saved.")
        //        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
//        self.viewWillDisappear(true)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        OTMClient.sharedInstance().udacityFacebookPOSTLogin(userName: email.text!, password: password.text!, facebookToken: nil, isUdacity: true) {
            (success, errorString)  in
            if (success != nil) {
                // Convert the NSDictionary that is received as AnyObject to Dictionary
                let responseAsNSDictinory: Dictionary = (success as! NSDictionary) as Dictionary
                
                // Check if the response contains any error or not
                if ((responseAsNSDictinory.indexForKey("error")) != nil) {
                    let statusCode = success["status"]
                    let errorMessage = success["error"]
                    let messageString: String = "\(statusCode!) + , \(errorMessage!)"
                    
                    // If success returns with an error message we need to show it to the user as an alert
                    Dialog().okDismissAlert(titleStr: "Login Failed", messageStr: messageString , controller: self)
                } else {
                    // Login success
                    self.appDelegate.loggedOnUdacity = true
                    self.appDelegate.udacityKey = responseAsNSDictinory[OTMClient.ConstantsUdacity.ACCOUNT_KEY] as! String
                    self.appDelegate.udacitySessionId = responseAsNSDictinory[OTMClient.ConstantsUdacity.SESSION_ID] as! String
                    // Still need to redirect it to the next page as it's success logged
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                Dialog().okDismissAlert(titleStr: "Login Failed", messageStr: (errorString?.description)!, controller: self)
            }
        }
    }
    
    
    @IBAction func signUpAction(sender: UIButton) {
        DismissKeyboard()
        self.performSegueWithIdentifier("Signup", sender: self)
        
        //        let signupViewController:UdacitySignupViewController = UdacitySignupViewController()
        //        self.presentViewController(signupViewController, animated: true, completion: nil)
    }
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "Signup") {
//            let destinationNavigationController: UINavigationController = segue.destinationViewController as! UINavigationController
//            let targetController: UdacitySignupViewController = destinationNavigationController.topViewController as! UdacitySignupViewController
//        }
//    }
    
    // Facebook buttom is disabled
    @IBAction func signInFacebookButton(sender: UIButton) {
        DismissKeyboard()
    }
    
    
}

