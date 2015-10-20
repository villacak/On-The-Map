//
//  PostingViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/18/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit

class PostingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var textWithData: UITextView!
    
    var otmTabBarController: OTMTabBarController!
    var spinner: ActivityIndicatorView!
    
    var userData: UserData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otmTabBarController = tabBarController as! OTMTabBarController
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        subscribeToKeyboardNotifications()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    
    
    // Keyboard notify notification center the keyboard will show
    func keyboardWillShow(notification: NSNotification) {
        if (view.frame.origin.y >= 0 &&
            textWithData.isFirstResponder()) {
                view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    
    
    // Keyboard notify notification center the keyboard will hide
    func keyboardWillHide(notification: NSNotification) {
        if (view.frame.origin.y <= 0 && textWithData.isFirstResponder()) {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
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

    
    @IBAction func findOnTheMapAction(sender: AnyObject) {
        spinner = ActivityIndicatorView(text: "Saving...")
        view.addSubview(spinner)

        assembleUserData();
        var responseAsNSDictinory: Dictionary<String, AnyObject>!
        
        OTMClient.sharedInstance().putPOSTStudentLocation(userData: userData){
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
                    self.otmTabBarController.userDataArray.append(self.userData);
                    self.dismissView()
                }
            })
        }
    }
    
    
    func assembleUserData() {
        userData = UserData()
        
    }
    
    
    func dismissView() {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func cancelAction(sender: AnyObject) {
        dismissView()
    }
    
}
