//
//  OTMTabBarController.swift
//  On The Map
//
//  Class extending UITabBarController, to share some variables
//  across tab, to redice the amount of controll passing and receiving data
//  at each segue
//
//  Created by Klaus Villaca on 10/6/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit

class OTMTabBarController: UITabBarController {
    
    var loggedOnUdacity: Bool!
    var userDataDic: Dictionary<String, UserData> =  Dictionary<String, UserData>()
    var udacityKey: String = OTMClient.ConstantsGeneral.EMPTY_STR
    var udacitySessionId: String = OTMClient.ConstantsGeneral.EMPTY_STR
    var udacityUserId: String = OTMClient.ConstantsGeneral.EMPTY_STR
    

}
