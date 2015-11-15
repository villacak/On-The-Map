//
//  OTMDomainUtils.swift
//  On The Map
//
//  Created by Klaus Villaca on 11/15/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import MapKit

class OTMDomainUtils: NSObject {

    var mapPoints: [MKPointAnnotation] = [MKPointAnnotation]()
    var userDataDic: Dictionary<String, UserData> = Dictionary<String, UserData>()
    var localUserData: UserData = UserData()
    
    var loggedOnUdacity: Bool = false
    
    var udacityKey: String = OTMClient.ConstantsGeneral.EMPTY_STR
    var udacitySessionId: String = OTMClient.ConstantsGeneral.EMPTY_STR
    var udacityUserId: String = OTMClient.ConstantsGeneral.EMPTY_STR
    
    
    override init(){ }
}
