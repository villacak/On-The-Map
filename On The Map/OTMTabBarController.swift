//
//  OTMTabBarController.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/6/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit

class OTMTabBarController: UITabBarController {
    
    var loggedOnUdacity: Bool!
    var userDataDic: Dictionary<String, UserData>! //[UserData?] = [UserData?]()
    var udacityKey: String = OTMClient.ConstantsGeneral.EMPTY_STR
    var udacitySessionId: String = OTMClient.ConstantsGeneral.EMPTY_STR
    
//    var locationManager: CLLocationManager?
}
