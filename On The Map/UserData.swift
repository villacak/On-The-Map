//
//  UserData.swift
//  On The Map
//
//  Created by Klaus Villaca on 9/27/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation
import UIKit
import Parse

/*
 * "uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\"
 *
 */
struct UserData {
    
    var objectId: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaUrl: String?
    var latitude: Double?
    var longitude: Double?
    var createdAt: NSDate?
    var updatedAt: NSDate?
    var ACL: PFACL!
    
    
    
    
    init() {
        objectId = OTMClient.ConstantsGeneral.EMPTY_STR
        uniqueKey = OTMClient.ConstantsGeneral.EMPTY_STR
        firstName = OTMClient.ConstantsGeneral.EMPTY_STR
        lastName = OTMClient.ConstantsGeneral.EMPTY_STR
        mapString = OTMClient.ConstantsGeneral.EMPTY_STR
        mediaUrl = OTMClient.ConstantsGeneral.EMPTY_STR
        latitude = 0.00
        longitude = 0.00
        createdAt = NSDate()
        updatedAt = NSDate()
        
        let acl = PFACL()
        acl.setPublicReadAccess(true)
        acl.setPublicWriteAccess(true)
        ACL = acl
    }
    
    init(objectId: String!, uniqueKey: String!, firstName: String!, lastName: String!,  mapString: String!, mediaUrl: String!, latitude: Double!, longitude: Double!, createdAt: NSDate!, updatedAt: NSDate!) {
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaUrl = mediaUrl
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = updatedAt
        self.updatedAt = updatedAt
    }
    
}
