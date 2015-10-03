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
    func udacityFacebookPOSTLogin(userName userName: String?, password: String?, facebookToken: String?, isUdacity: Bool, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        
        let request = NSMutableURLRequest(URL: NSURL(string: ConstantsUdacity.UDACITY_LOG_IN_OUT)!)
        request.HTTPMethod = ConstantsRequest.METHOD_POST
        request.addValue(ConstantsRequest.MIME_TYPE, forHTTPHeaderField: ConstantsRequest.ACCEPT)
        request.addValue(ConstantsRequest.MIME_TYPE, forHTTPHeaderField: ConstantsRequest.CONTENT_TYPE)
        request.HTTPBody = (isUdacity == true) ? buildUdacityBodyRequest(userName: userName!, password: password!) :
                                                 buildFacebookBodyRequest(fbToken: facebookToken!)

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if (error != nil) {
                completionHandler(result: nil, error: error)
            } else {
                let newData: NSData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(newData, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch)
                }
            }
        }
        task.resume()
        return task
    }
    
    
    
    // Udacity - Logout
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
    
    

    // Udacity - Get user data
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
    
    
    
    // Utils function to build Udacity json
    func buildUdacityBodyRequest(userName userName: String, password: String)-> NSData {
        var bodyJson: NSData!
        do {
            var tempDictionary: [String: AnyObject] = ConstantsUdacity.UDACITY_LOGIN_JSON
            var udacityTemp: [String: AnyObject] = (tempDictionary[ConstantsUdacity.UDACITY]! as? [String: AnyObject])!
            udacityTemp[ConstantsUdacity.USERNAME] = userName
            udacityTemp[ConstantsUdacity.PASSWORD] = password
            tempDictionary[ConstantsUdacity.UDACITY] = udacityTemp
            
            bodyJson = try NSJSONSerialization.dataWithJSONObject(tempDictionary, options: [])
        } catch let errorCatch as NSError {
            bodyJson = buildErrorMessage(errorCatch)
        }
        return bodyJson
    }

    
    // Utils function to build Facebook jso
    func buildFacebookBodyRequest(fbToken fbToken: String)-> NSData {
        var bodyJson: NSData!
        do {
            var tempDictionary: [String: AnyObject] = ConstantsUdacity.UDACITY_FACEBOOK_JSON
            var udacityTemp: [String: AnyObject] = (tempDictionary[ConstantsUdacity.FACEBOOK_MOBILE]! as? [String: AnyObject])!
            udacityTemp[ConstantsUdacity.FACEBOOK_ACCESS_TOKEN] = fbToken
            tempDictionary[ConstantsUdacity.FACEBOOK_MOBILE] = udacityTemp
            
            bodyJson = try NSJSONSerialization.dataWithJSONObject(tempDictionary, options: [])
        } catch let errorCatch as NSError {
            bodyJson = buildErrorMessage(errorCatch)
        }
        return bodyJson
    }
    
    
    // Build error message
    func buildErrorMessage(error: NSError)->NSData {
        let dataReadyToReturn: NSData = ("{\"errorMessage\": \"" + error.description + "\"}").dataUsingEncoding(NSUTF8StringEncoding)!
        return dataReadyToReturn
    }
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
}
