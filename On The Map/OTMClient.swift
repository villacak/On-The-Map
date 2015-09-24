//
//  OTMClient.swift
//  On The Map
//
//  Created by Klaus Villaca on 9/22/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation


class OTMClient: NSObject {
    
    
    // Encode the Dictionary Strings
    func encodeParameters(params params: [String: String]) -> String {
        let queryItems = params.map() { NSURLQueryItem(name:$0, value:$1)}
        let components = NSURLComponents()
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? ConstantsGeneral.EMPTY_STR
    }

    
    /*
     * Udacity - Login
     *
     * "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
     * 
     * "{\"facebook_mobile\": {\"access_token\": \"<Facebook Token>"}}"
     */
    func udacityFacebookPOSTLogin(bodyJson bodyJson: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: ConstantsUdacity.UDACITY_LOG_IN_OUT)!)
        request.HTTPMethod = ConstantsRequest.METHOD_POST
        request.addValue(ConstantsRequest.MIME_TYPE, forHTTPHeaderField: ConstantsRequest.ACCEPT)
        request.addValue(ConstantsRequest.MIME_TYPE, forHTTPHeaderField: ConstantsRequest.CONTENT_TYPE)
        request.HTTPBody = bodyJson.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        return task
    }
    
    
    /*
     * Udacity - Logout
     */
    func udacityPOSTLogout(completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: ConstantsUdacity.UDACITY_LOG_IN_OUT)!)
        request.HTTPMethod = ConstantsRequest.METHOD_DELETE
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == ConstantsUdacity.COOKIE_NAME { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: ConstantsUdacity.COOKIE_TOKEN)
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        return task
    }
    
    
    /*
     * Udacity - Get user data
     */
    func udacityPOSTGetUserData(userId: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: ConstantsUdacity.UDACITY_GET_PUBLIC_DATA + userId)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        return task
    }
    
    // MARK: - GET
//    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
//        
//        /* 1. Set the parameters */
//        var mutableParameters = parameters
//        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
//        
//        /* 2/3. Build the URL and configure the request */
//        let urlString = Constants.BaseURLSecure + method + TMDBClient.escapedParameters(mutableParameters)
//        let url = NSURL(string: urlString)!
//        let request = NSURLRequest(URL: url)
//        
//        /* 4. Make the request */
//        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
//            
//            /* 5/6. Parse the data and use the data (happens in completion handler) */
//            if let error = downloadError {
//                let newError = TMDBClient.errorForData(data, response: response, error: error)
//                completionHandler(result: nil, error: downloadError)
//            } else {
//                TMDBClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
//            }
//        }
//        
//        /* 7. Start the request */
//        task.resume()
//        
//        return task
//    }
//

    // MARK: - POST
//    func taskForPOSTUdacityMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
//        
//        /* 1. Set the parameters */
//        var mutableParameters = parameters
//        mutableParameters[ConstantsParse.API_KEY] = Constants.ApiKey
//        
//        /* 2/3. Build the URL and configure the request */
//        let urlString = Constants.BaseURLSecure + method + TMDBClient.escapedParameters(mutableParameters)
//        let url = NSURL(string: urlString)!
//        let request = NSMutableURLRequest(URL: url)
//        var jsonifyError: NSError? = nil
//        request.HTTPMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        do {
//            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
//        } catch let error as NSError {
//            jsonifyError = error
//            request.HTTPBody = nil
//        }
//        
//        /* 4. Make the request */
//        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
//            
//            /* 5/6. Parse the data and use the data (happens in completion handler) */
//            if let error = downloadError {
//                let newError = TMDBClient.errorForData(data, response: response, error: error)
//                completionHandler(result: nil, error: downloadError)
//            } else {
//                TMDBClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
//            }
//        }
//        
//        /* 7. Start the request */
//        task.resume()
//        
//        return task
//    }

}
