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
        
        //        let testObject = PFObject(className: "TestObject")
        //        testObject["foo"] = "bar"
        //        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        //            print("Object has been saved.")
        //        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        self.viewWillDisappear(true)
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
        OTMClient.sharedInstance().udacityFacebookPOSTLogin(userName: email.text!, password: password.text!) {
            (success, errorString)  in
            if (success != nil) {
                
                print(success!)
                let responseAsNSDictinory: Dictionary = (success as! NSDictionary) as Dictionary
                
                //                    let jsonDict = try (NSJSONSerialization.JSONObjectWithData(responseAsNSDictinory, options: nil) as NSDictionary) as Dictionary
                
                if ((responseAsNSDictinory.indexForKey("error")) != nil) {
                    let statusCode = success["status"]
                    let errorMessage = success["error"]
                    let messageString: String = "\(statusCode!) + , \(errorMessage!)"
                    Dialog().okDismissAlert(titleStr: "Login Failed", messageStr: messageString , controller: self)
                } else {
                    // Login success
                    self.appDelegate.loggedOnFacebook = false
                }
            } else {
                Dialog().okDismissAlert(titleStr: "Login Failed", messageStr: (errorString?.description)!, controller: self)
            }
        }
    }
    
    
    @IBAction func signUpAction(sender: UIButton) {
        DismissKeyboard()
    }
    
    
    @IBAction func signInFacebookButton(sender: UIButton) {
        DismissKeyboard()
    }
    
    
}

