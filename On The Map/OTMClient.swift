//
//  OTMClient.swift
//  On The Map
//
//  Class with all Requests using asyncronous calls and completion hanlders
//
//  Created by Klaus Villaca on 9/22/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//


import UIKit
import Parse


class OTMClient: NSObject {
    
    
    //
    // Encode the Dictionary Strings - Just let it here just in case we need further use it
    //
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
    func udacityPOSTLogin(userName userName: String?, password: String?, completionHandler: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: ConstantsUdacity.UDACITY_LOG_IN_OUT)!)
        request.HTTPMethod = ConstantsRequest.METHOD_POST
        request.addValue(ConstantsRequest.MIME_TYPE_POST, forHTTPHeaderField: ConstantsRequest.ACCEPT)
        request.addValue(ConstantsRequest.MIME_TYPE_POST, forHTTPHeaderField: ConstantsRequest.CONTENT_TYPE)
        
        let utils: Utils = Utils()
        request.HTTPBody = utils.buildUdacityBodyRequest(userName: userName!, password: password!)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if (error != nil) {
                completionHandler(result: nil, error: error?.localizedDescription)
            } else {
                utils.addCookieToSharedStorage(response!)
                let newData: NSData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(newData, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch.localizedDescription)
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
    func udacityPOSTLogout(completionHandler: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
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
                completionHandler(result: nil, error: error?.localizedDescription)
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                let utils: Utils = Utils()
                utils.deleteCookies()
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(newData, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch.localizedDescription)
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
    func udacityPOSTGetUserData(udacityId udacityId: String, completionHandler: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: ConstantsUdacity.UDACITY_GET_PUBLIC_DATA + udacityId)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error?.localizedDescription)
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(newData, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch.localizedDescription)
                }
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
    func parseGETStudentLocations( limit limit: String?, skip: String?, order: OTMServicesNameEnum?, completionHandler: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        
        let utils: Utils = Utils()
        let tempUrl: String = utils.getUrlForParameters(limitP: limit, skipP: skip, orderP: order)
        let urlSelected: NSURL = NSURL(string: tempUrl)!
        let request = NSMutableURLRequest(URL: urlSelected)
        request.addValue(OTMClient.ConstantsParse.APPLICATION_ID_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.APPLICATION_ID_STR)
        request.addValue(OTMClient.ConstantsParse.REST_API_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.REST_API_KEY_STR)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error?.localizedDescription)
            } else {
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch.localizedDescription)
                }
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
    func putPOSTStudentLocation(userData userData: UserData, completionHandler: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.ConstantsParse.PARSE_STUDENT_LOCATION_URL)!)
        request.HTTPMethod = OTMClient.ConstantsRequest.METHOD_POST
        request.addValue(OTMClient.ConstantsParse.APPLICATION_ID_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.APPLICATION_ID_STR)
        request.addValue(OTMClient.ConstantsParse.REST_API_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.REST_API_KEY_STR)
        request.addValue(OTMClient.ConstantsRequest.MIME_TYPE_POST, forHTTPHeaderField: OTMClient.ConstantsRequest.CONTENT_TYPE)
        
        let utils: Utils = Utils()
        request.HTTPBody = utils.buildParseBodyRequest(userData: userData)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error?.localizedDescription)
            } else {
                do {
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch.localizedDescription)
                }
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
    func queryGETStudentLocation(whereStr whereStr: String, completionHandler: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        let urlString: String = "https://api.parse.com/1/classes/StudentLocation?where=\(whereStr)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(OTMClient.ConstantsParse.APPLICATION_ID_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.APPLICATION_ID_STR)
        request.addValue(OTMClient.ConstantsParse.REST_API_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.REST_API_KEY_STR)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error?.localizedDescription)
            } else {
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch.localizedDescription)
                }
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
     func updatingPUTStudentLocation(userData userData: UserData, completionHandler: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(userData.objectId)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = OTMClient.ConstantsRequest.METHOD_PUT
        request.addValue(OTMClient.ConstantsParse.APPLICATION_ID_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.APPLICATION_ID_STR)
        request.addValue(OTMClient.ConstantsParse.REST_API_KEY, forHTTPHeaderField: OTMClient.ConstantsParse.REST_API_KEY_STR)
        request.addValue(OTMClient.ConstantsRequest.MIME_TYPE_POST, forHTTPHeaderField: OTMClient.ConstantsRequest.CONTENT_TYPE)
        
        let utils: Utils = Utils()
        request.HTTPBody = utils.buildParseBodyRequest(userData: userData)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error?.localizedDescription)
            } else {
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
                } catch let errorCatch as NSError {
                    completionHandler(result: nil, error: errorCatch.localizedDescription)
                }
            }
        }
        task.resume()
        return task
    }
    
    
    //
    // To have the same instance been shared.
    //
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
}
