//
//  OTMTabBarController.swift
//  On The Map
//
//  Class extending UITabBarController, to share variables
//  across tab, to redice the amount of controll passing and
//  receiving data at each segue
//
//  Created by Klaus Villaca on 10/6/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import MapKit

class OTMTabBarController: UITabBarController {
    
    var appDelegate: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)

    
    
}
