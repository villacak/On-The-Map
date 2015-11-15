//
//  UserData.swift
//  On The Map
//
//  Created by Klaus Villaca on 9/27/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation
import UIKit
import MapKit

//
// Struct for the data across the app
//
struct UserData {
    
    var objectId: String = ""
    var uniqueKey: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var mapString: String = ""
    var mediaURL: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var createdAt: String = ""
    var updatedAt: String = ""
    var userLocation: MKPointAnnotation = MKPointAnnotation()
    
    
    //
    // Empty initializer
    //
    init() {}
    
    
    //
    // Init with values
    //
    init(objectId: String!, uniqueKey: String!, firstName: String!, lastName: String!,  mapString: String!, mediaURL: String!, latitude: Double!, longitude: Double!, createdAt: String!, updatedAt: String!, userLocation: MKPointAnnotation!) {
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = updatedAt
        self.updatedAt = updatedAt
        if let tempUserLocation = userLocation {
            self.userLocation = tempUserLocation
        } else {
            self.userLocation = MKPointAnnotation()
        }
    }
    
    
    //
    // Init from a dictionary
    //
    init(dictionaryForUserData: Dictionary<String, AnyObject>) {
        if let tempObjectId = dictionaryForUserData["objectId"] {
            objectId = tempObjectId as! String
        }
        
        if let tempUniqueKey = dictionaryForUserData["uniqueKey"] {
            uniqueKey = tempUniqueKey as! String
        }
        
        if let tempFirstName = dictionaryForUserData["firstName"] {
            firstName = tempFirstName as! String
        }
        
        if let tempLastName = dictionaryForUserData["lastName"] {
            lastName = tempLastName as! String
        }
        
        if let tempMapString = dictionaryForUserData["mapString"] {
            mapString = tempMapString as! String
        }
        
        if let tempMediaURL = dictionaryForUserData["mediaURL"] {
            mediaURL = tempMediaURL as! String
        }
        
        if let tempLatitude = dictionaryForUserData["latitude"] {
            latitude = tempLatitude as! Double
        }
        
        if let tempLongitude = dictionaryForUserData["longitude"] {
            longitude = tempLongitude as! Double
        }
        
        if let tempCreatedAt = dictionaryForUserData["createdAt"] {
            createdAt = tempCreatedAt as! String
        }
        
        if let tempUpdatedAt = dictionaryForUserData["updatedAt"] {
            updatedAt = tempUpdatedAt as! String
        }
        
        
        let objectAnnotation: MKPointAnnotation = MKPointAnnotation()
        if (latitude != 0 && longitude != 0) {
            let fullName: String = "\(firstName) \(lastName)"
            let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            objectAnnotation.coordinate = pinLocation
            objectAnnotation.title = fullName
            objectAnnotation.subtitle = mediaURL
        }
        userLocation = objectAnnotation
    }
    
}
