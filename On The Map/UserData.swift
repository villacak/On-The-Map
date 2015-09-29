//
//  UserData.swift
//  On The Map
//
//  Created by Klaus Villaca on 9/27/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation


struct UserData {
    
    var name: String?
    var url: String?
    var latitude: Double?
    var longitude: Double?
    var place: String?
    
    
    init() {
        name = OTMClient.ConstantsGeneral.EMPTY_STR
        url = OTMClient.ConstantsGeneral.EMPTY_STR
        latitude = 0.00
        longitude = 0.00
        place = OTMClient.ConstantsGeneral.EMPTY_STR
    }
    
    init(name: String!, url: String!, latitude: Double!, longitude: Double!, place: String!) {
        self.name = name
        self.url = url
        self.latitude = latitude
        self.longitude = longitude
        self.place = place
    }
    
}
