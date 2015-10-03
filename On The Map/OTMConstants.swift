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
        static let API_KEY_STR: String = "API_KEY"
        static let API_KEY: String = "8giE02DqBln6EvyGCirPg6FBYpG8zNFZusGFamhq"
        
        static let CLIENT_KEY_STR: String = "CLIENT_KEY_STR"
        static let CLIENT_KEY: String = "aiBuGRmnE489l7VeXBLCzBoFzAObn0SDgYRZ1OBk"
    }
    
    
    struct ConstantsUdacity {
        static let UDACITY_LOG_IN_OUT: String = "https://www.udacity.com/api/session"
        static let UDACITY_GET_PUBLIC_DATA: String = "https://www.udacity.com/api/users/"
        static let COOKIE_NAME: String = "XSRF-TOKEN"
        static let COOKIE_TOKEN: String = "X-XSRF-TOKEN"
        
        static let UDACITY: String = "udacity"
        static let USERNAME: String = "username"
        static let PASSWORD: String = "password"
        static let ACCOUNT_KEY: String = "key"
        static let SESSION_ID: String = "id"
        
        static let FACEBOOK_MOBILE: String = "facebook_mobile"
        static let FACEBOOK_ACCESS_TOKEN: String = "access_token"

        
        static let UDACITY_LOGIN_JSON: [String : AnyObject] = [UDACITY : [
                                                                    USERNAME : "",
                                                                    PASSWORD : ""
                                                                  ]
                                                              ]
        
        static let UDACITY_FACEBOOK_JSON: [String : AnyObject] = [FACEBOOK_MOBILE : [
                                                                    FACEBOOK_ACCESS_TOKEN : ""
                                                                      ]
                                                                 ]
    }

    
    struct ConstantsRequest {
        static let METHOD_POST = "POST"
        static let METHOD_GET = "GET"
        static let METHOD_DELETE = "DELETE"
        
        static let MIME_TYPE = "application/json"
        static let CONTENT_TYPE = "Content-Type"
        static let ACCEPT = "Accept"
    }
    
    
    struct ConstantsGeneral {
        static let EMPTY_STR = ""
    }
    
    struct ConstantsMessages {
        static let INVALID_LOGIN = "Username and/or passord is wrong!"
        static let LOGGED_OUT_SUCCESS = "You have been logged out with success"
        static let DOUBLE_CREDENTIALS = "Did not specify exactly one credential"
        static let INVALID_DATA = "Invalid data"
    }
}