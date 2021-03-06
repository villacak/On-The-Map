//
//  Dialog.swift
//  On The Map
//
//  Created by Klaus Villaca on 9/29/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation
import UIKit


class Dialog: NSObject {

    //
    // UIAlertDisplay with one ok buttom to dismiss
    //
    func okDismissAlert(titleStr titleStr: String, messageStr: String, controller: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.Alert)
        let okDismiss: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(okDismiss)
        controller.presentViewController(alert, animated: true, completion: {})
    }
}
