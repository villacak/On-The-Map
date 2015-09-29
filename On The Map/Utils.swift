//
//  Utils.swift
//  On The Map
//
//  Created by Klaus Villaca on 9/28/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//
//  Class to be exended to reuse code for hidde and show keyboard moving
//  the entry field to be above the keyboard.
//

import UIKit

class ViewControllerWithKeyboardControl: UIViewController {
    
    var appDelegate: AppDelegate!
    var tempUiTextField: UITextField!
    var tempView: UIView!
    var tempViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
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
}

