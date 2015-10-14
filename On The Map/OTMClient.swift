//
//  OTMClient.swift
//  On The Map
//
//  Created by Klaus Villaca on 9/22/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation
import UIKit


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
    * Facebook functionality is disabled
    * "{\"facebook_mobile\": {\"access_token\": \"<Facebook Token>"}}"
    */
    func udacityPOSTLogin(userName userName: String?, password: String?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: ConstantsUdacity.UDACITY_LOG_IN_OUT)!)
        request.HTTPMethod = ConstantsRequest.METHOD_POST
        request.addValue(ConstantsRequest.MIME_TYPE, forHTTPHeaderField: ConstantsRequest.ACCEPT)
        request.addValue(ConstantsRequest.MIME_TYPE, forHTTPHeaderField: ConstantsRequest.CONTENT_TYPE)
        request.HTTPBody = buildUdacityBodyRequest(userName: userName!, password: password!)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if (error != nil) {
                completionHandler(result: nil, error: error)
            } else {
                self.addCookieToSharedStorage(response!)
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
            if (error != nil) {
                completionHandler(result: nil, error: error)
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
//                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
                self.deleteCookies()
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
    
    
    // Extract token form response and store on shared cookie storage
    func addCookieToSharedStorage(response: NSURLResponse) {
        if let httpResponse = response as? NSHTTPURLResponse {
            
            if let headerFields: [String: String] = httpResponse.allHeaderFields as? [String: String] {
                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(headerFields, forURL: response.URL!)
                //                        let cookies: [NSHTTPCookie] = NSHTTPCookie.cookiesWithResponseHeaderFields(httpResponse.allHeaderFields, forURL: response.URL!) as! [NSHTTPCookie]
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response.URL!, mainDocumentURL: nil)
                //                var cookieCount: Int = 0
                for cookie in cookies {
                    var cookieProperties = [String: AnyObject]()
                    cookieProperties[NSHTTPCookieName] = cookie.name //"\(ConstantsUdacity.COOKIE_NAME)\(cookieCount++)" cookie.name
                    cookieProperties[NSHTTPCookieValue] = cookie.value
                    cookieProperties[NSHTTPCookieDomain] = cookie.domain
                    cookieProperties[NSHTTPCookiePath] = cookie.path
                    cookieProperties[NSHTTPCookieVersion] = NSNumber(integer: cookie.version)
                    cookieProperties[NSHTTPCookieExpires] = NSDate().dateByAddingTimeInterval(31536000)
                    
                    let newCookie = NSHTTPCookie(properties: cookieProperties)
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(newCookie!)
                }
            }
        }
        
    }
    
    
    func deleteCookies() {
        let cookieStorage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = cookieStorage.cookies as [NSHTTPCookie]?
//        print("Cookies.count: \(cookies!.count)")
        for cookie in cookies! {
//            print("name: \(cookie.name) value: \(cookie.value)")
            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
        }
    }
    
    
    
    // Build error message
    func buildErrorMessage(error: NSError)->NSData {
        let dataReadyToReturn: NSData = ("{\"errorMessage\": \"" + error.description + "\"}").dataUsingEncoding(NSUTF8StringEncoding)!
        return dataReadyToReturn
    }
    
    
    
    // Success login helper,
    // Stores key and id in AppDelegate to use for sub-sequent requests
    func successResponse(responseDictionary: Dictionary<String, AnyObject>, otmTabBarController: OTMTabBarController)-> Bool {
        var isSuccess:Bool = false
        otmTabBarController.loggedOnUdacity = true
        let account: Dictionary<String, AnyObject> = responseDictionary[OTMClient.ConstantsUdacity.ACCOUNT] as! Dictionary<String, AnyObject>
        
        otmTabBarController.udacityKey = account[OTMClient.ConstantsUdacity.ACCOUNT_KEY] as! String
        
        let session: Dictionary<String, AnyObject> = responseDictionary[OTMClient.ConstantsUdacity.SESSION] as! Dictionary<String, AnyObject>
        
        otmTabBarController.udacitySessionId = session[OTMClient.ConstantsUdacity.SESSION_ID] as! String
        
        if (otmTabBarController.udacityKey != OTMClient.ConstantsGeneral.EMPTY_STR && otmTabBarController.udacitySessionId != OTMClient.ConstantsGeneral.EMPTY_STR) {
            isSuccess = true
        }
        return isSuccess
    }
    
    
    // Parse error returned
    func parseErrorReturned(responseDictionary: Dictionary<String, AnyObject>)-> String {
        
        var statusCode: String!
        var message: String!
        var messageToReturn: String!
        
        for (key, value) in responseDictionary {
            if (key == OTMClient.ConstantsUdacity.STATUS) {
                statusCode = String(value as! Int)
            }
            if (key == OTMClient.ConstantsUdacity.ERROR) {
                message = value as! String
                messageToReturn = "\(statusCode), \(message)"
            }
        }
        return messageToReturn
    }
    
    
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
}
