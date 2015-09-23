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
        static let API_KEY_PART: String = "Your API Key"
        static let CLIENT_KEY: String = "The client key"
    }
    
    
    struct ConstantsUdacity {
        static let UDACITY_LOG_IN_OUT: String = "https://www.udacity.com/api/session"
        static let UDACITY_GET_PUBLIC_DATA: String = "https://www.udacity.com/api/users/"
        static let COOKIE_TOKEN: String = "XSRF-TOKEN"
        static let HEADER_TOKEN: String = "X-XSRF-TOKEN"
    }

    
    struct ConstantsRequest {
        static let METHOD_POST = "POST"
        static let METHOD_GET = "GET"
        static let METHOF_DELETE = "DELETE"
        
        static let MIME_TYPE = "application/json"
        static let CONTENT_TYPE = "Content-Type"
        static let ACCEPT = "Accept"
    }
    
}