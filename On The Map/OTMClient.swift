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
    * https://www.udacity.com/api/session
    *
    * Method : POST
    *
    * Parameters:
    * udacity - Dictionary
    * username - String, may be user name or email
    * password - String
    *
    */
    func udacityPOSTLogin(userName userName: String?, password: String?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: ConstantsUdacity.UDACITY_LOG_IN_OUT)!)
        request.HTTPMethod = ConstantsRequest.METHOD_POST
        request.addValue(ConstantsRequest.MIME_TYPE_POST, forHTTPHeaderField: ConstantsRequest.ACCEPT)
        request.addValue(ConstantsRequest.MIME_TYPE_POST, forHTTPHeaderField: ConstantsRequest.CONTENT_TYPE)
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
    
    
    
    /*
    * Udacity - Logout
    *
    *  https://www.udacity.com/api/session
    *
    *  Method : DELETE
    *
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
            if (error != nil) {
                completionHandler(result: nil, error: error)
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
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
    
    
    /*
    * Get User Data
    *
    * https://www.udacity.com/api/users/<user_id>
    *
    * Method : GET
    *
    * parameter
    * userId - String, userId that is retrieved once the user has logged in with success
    *
    */
    func udacityPOSTGetUserData(userId: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: ConstantsUdacity.UDACITY_GET_PUBLIC_DATA + userId)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(newData, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch)
                }
                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            }
        }
        task.resume()
        return task
    }
    
    
    
    
    /*
    * Get Students Locations
    *
    * https://api.parse.com/1/classes/StudentLocation
    *
    * Method : GET
    *
    * parameters
    * limit - Number, specifies the maximum number of StudentLocation objects to return in the JSON response
    * skip - Number, use this parameter with limit to paginate through results
    * order - String, a comma-separate list of key names that specify the sorted order of the results
    *                 Prefixing a key name with a negative sign reverses the order (default order is descending)
    *
    */
    func parseGETStudentLocations(limit limit: String?, skip: String?, order: OTMServicesNameEnum?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let tempUrl: String = getUrlForParameters(limitP: limit, skipP: skip, orderP: order)
        let urlSelected: NSURL = NSURL(string: tempUrl)!
        let request = NSMutableURLRequest(URL: urlSelected)
        request.addValue(OTMClient.ConstantsParse.APPLICATION_ID_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.APPLICATION_ID_STR)
        request.addValue(OTMClient.ConstantsParse.API_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.API_KEY_STR)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
            } else {
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch)
                }
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            }
        }
        task.resume()
        return task
    }
    
    
    /*
     * putPOSTStudentLocation
     *
     * https://api.parse.com/1/classes/StudentLocation
     * Method: POST
     *
     * Parameters
     * Refer fields from Domain -> UserData
     */
    func putPOSTStudentLocation(userData userData: UserData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.ConstantsParse.PARSE_STUDENT_LOCATION_URL)!)
        request.HTTPMethod = OTMClient.ConstantsRequest.METHOD_POST
        request.addValue(OTMClient.ConstantsParse.APPLICATION_ID_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.APPLICATION_ID_STR)
        request.addValue(OTMClient.ConstantsParse.API_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.API_KEY_STR)
        request.addValue(OTMClient.ConstantsRequest.MIME_TYPE_POST, forHTTPHeaderField: OTMClient.ConstantsRequest.CONTENT_TYPE)
        request.HTTPBody = buildParseBodyRequest(userData: userData)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
            } else {
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch)
                }
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            }
        }
        task.resume()
        return task
    }
    
    
    /*
     * Query Student Location
     *
     * https://api.parse.com/1/classes/StudentLocation
     *
     * Method : GET
     *
     * Parameters
     * where - Parse Query a SQL-like query allowing you to check if an object value matches some target value
     *
     * https://www.parse.com/docs/rest/guide/#queries-arrays
     */
    func queryGETStudentLocation(whereStr whereStr: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let urlString: String = "https://api.parse.com/1/classes/StudentLocation?where=\(whereStr)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(OTMClient.ConstantsParse.APPLICATION_ID_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.APPLICATION_ID_STR)
        request.addValue(OTMClient.ConstantsParse.API_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.API_KEY_STR)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
            } else {
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch)
                }
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            }
        }
        task.resume()
        return task
    }
    
    
    /*
     * updatingPUTStudentLocation
     *
     * https://api.parse.com/1/classes/StudentLocation/<objectId>
     *
     * Method : PUT
     *
     * Parameters
     * objectId - String, the object ID of the StudentLocation to update; specify the object ID right after StudentLocation
     *
     */
     func updatingPUTStudentLocation(objectId objectId: String, userData: UserData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(objectId)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = OTMClient.ConstantsRequest.METHOD_PUT
        request.addValue(OTMClient.ConstantsParse.APPLICATION_ID_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.APPLICATION_ID_STR)
        request.addValue(OTMClient.ConstantsParse.API_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.API_KEY_STR)
        request.addValue(OTMClient.ConstantsRequest.MIME_TYPE_POST, forHTTPHeaderField: OTMClient.ConstantsRequest.CONTENT_TYPE)
        request.HTTPBody = buildParseBodyRequest(userData: userData)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
            } else {
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch)
                }
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            }
        }
        task.resume()
        return task
    }
    
        
        
    
    /*
     * Form the URL dependgin on the parameters received.
     * Returns the standard url if doesn't match any of those conditions
     * 
     * limit - String
     * skip - String
     * order - OTMServicesNameEnum()
     */
    func getUrlForParameters(limitP limitP: String?, skipP: String?, orderP: OTMServicesNameEnum?) -> String {
        var urlForChange: String = OTMClient.ConstantsParse.PARSE_STUDENT_LOCATION_URL
        if (limitP != nil && skipP != nil && orderP != nil) {
            urlForChange += "?limit=\(limitP)&skip=\(skipP)&order=\(orderP)"
        } else if (limitP != nil && skipP != nil) {
            urlForChange += "?limit=\(limitP)&skip=\(skipP)"
        } else if (limitP != nil) {
            urlForChange += "?limit=\(limitP)"
        } else if (limitP == nil && skipP == nil && orderP != nil) {
            urlForChange += "?order=\(orderP)"
        }
        return urlForChange
    }
    
    
    // Utils functions to build the Parse json
    // "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}"
    func buildParseBodyRequest(userData userData: UserData) -> NSData {
        var bodyJson: NSData!
        do {
            var tempDictionary: [String: AnyObject] = [String: AnyObject]()
            tempDictionary[OTMClient.ConstantsData.uniqueKey] = userData.uniqueKey
            tempDictionary[OTMClient.ConstantsData.firstName] = userData.firstName
            tempDictionary[OTMClient.ConstantsData.lastName] = userData.lastName
            tempDictionary[OTMClient.ConstantsData.mapString] = userData.mapString
            tempDictionary[OTMClient.ConstantsData.mediaUrl] = userData.mediaUrl
            tempDictionary[OTMClient.ConstantsData.latitude] = userData.latitude
            tempDictionary[OTMClient.ConstantsData.longitude] = userData.longitude
            
            bodyJson = try NSJSONSerialization.dataWithJSONObject(tempDictionary, options: [])
        } catch let errorCatch as NSError {
            bodyJson = buildErrorMessage(errorCatch)
        }
        
        
        return bodyJson
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
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response.URL!, mainDocumentURL: nil)
                for cookie in cookies {
                    var cookieProperties = [String: AnyObject]()
                    cookieProperties[NSHTTPCookieName] = cookie.name
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
        for cookie in cookies! {
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
