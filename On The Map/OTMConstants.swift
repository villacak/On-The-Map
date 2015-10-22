//
//  OTMConstants.swift
//  On The Map
//
//  Created by Klaus Villaca on 9/22/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation


extension OTMClient {
    
    struct ConstantsParse {
        // MARK: Parse API Key
        static let CLIENT_KEY_STR: String = "X-Parse-REST-API-Key"
        static let CLIENT_API_KEY: String = "aiBuGRmnE489l7VeXBLCzBoFzAObn0SDgYRZ1OBk"
        
        static let REST_API_KEY_STR: String = "X-Parse-REST-API-Key"
        static let REST_API_KEY: String = "yENQUrV58F0e3ImCAGJEICDp6UcmAatBdahluzMp"
        
        static let APPLICATION_ID_STR: String = "X-Parse-Application-Id"
        static let APPLICATION_ID_KEY: String = "8giE02DqBln6EvyGCirPg6FBYpG8zNFZusGFamhq"
        
        static let PARSE_STUDENT_LOCATION_URL = "https://api.parse.com/1/classes/StudentLocation"
        
        static let RESULTS: String = "results"

    }
    
    
    struct ConstantsUdacity {
        static let UDACITY_LOG_IN_OUT: String = "https://www.udacity.com/api/session"
        static let UDACITY_GET_PUBLIC_DATA: String = "https://www.udacity.com/api/users/"
        static let UDACITY_SIGN_UP: String = "https://www.udacity.com/account/auth#!/signup"
        static let COOKIE_NAME: String = "XSRF-TOKEN"
        static let COOKIE_TOKEN: String = "X-XSRF-TOKEN"
        
        static let ACCOUNT: String = "account"
        static let SESSION: String = "session"
        static let UDACITY: String = "udacity"
        static let USERNAME: String = "username"
        static let PASSWORD: String = "password"
        static let ACCOUNT_KEY: String = "key"
        static let SESSION_ID: String = "id"
        static let STATUS: String = "status"
        static let ERROR: String = "error"
        static let USER: String = "user"
        
        static let UDACITY_LOGIN_JSON: [String : AnyObject] = [UDACITY : [
                                                                    USERNAME : "",
                                                                    PASSWORD : ""
                                                                  ]
                                                              ]
    }

    
    struct ConstantsRequest {
        static let METHOD_POST: String = "POST"
        static let METHOD_GET: String = "GET"
        static let METHOD_DELETE: String = "DELETE"
        static let METHOD_PUT: String = "PUT"
        
        static let MIME_TYPE_POST: String = "application/json"
        static let CONTENT_TYPE: String = "Content-Type"
        static let ACCEPT: String = "Accept"
    }
    
    
    struct ConstantsGeneral {
        static let EMPTY_STR: String = ""
        static let MAP_VIEW_VIEW: String = "MapViewSB"
    }
    
    struct ConstantsMessages {
        static let INVALID_LOGIN: String = "Username and/or passord is wrong!"
        static let LOGIN_FAILED: String = "Login Failed"
        static let LOGOUT_SUCCESS: String = "Logout Success"
        static let LOGOUT_SUCCESS_MESSAGE: String = "You have been logged out with success"
        static let DOUBLE_CREDENTIALS: String = "Did not specify exactly one credential"
        static let INVALID_DATA: String = "Invalid data"
        static let LOGIN_PROCESSING: String = "Login..."
        static let LOGOUT_PROCESSING: String = "Logout..."
        static let LOADING_DATA: String = "Loading..."
        static let LOADING_DATA_FAILED: String = "Loading data has failed"
        static let ERROR_UPDATING_LOCATION: String = "Error while updating location, "
    }
    
    struct ConstantsData {
        static let objectId: String = "objectId"
        static let uniqueKey: String = "uniqueKey"
        static let firstName: String = "firstName"
        static let firstNameUD: String = "first_name"
        static let lastName: String = "lastName"
        static let lastNameUD: String = "last_name"
        static let mapString: String = "mapString"
        static let mediaUrl: String = "mediaUrl"
        static let latitude: String = "latitude"
        static let longitude: String = "longitude"
        static let createdAt: String = "createdAt"
        static let updatedAt: String = "updatedAt"
    }
}