//
//  Utils.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/28/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//


import UIKit
import MapKit


class Utils: NSObject {
    
    
    //
    // Populate the pins from the list into the map
    //
    func populateLocationList(mapData mapData: Dictionary<String, AnyObject>, var uiTabBarController: OTMTabBarController) -> (annotationReturn: [MKPointAnnotation], uiTabBarController: OTMTabBarController) {
        var annotationReturn: [MKPointAnnotation] = [MKPointAnnotation]()
        // Populate the map with the list
        if mapData.count > 0 {
            for (_, value) in mapData {
                let valuesDic: [Dictionary<String, AnyObject>] = value as! [Dictionary<String, AnyObject>]
                let tempTupplesReturn = extractArrayOfDictionary(arrayToExtract: valuesDic, uiTabBarController: uiTabBarController)
                annotationReturn = tempTupplesReturn.annotationArrayReturn
                uiTabBarController = tempTupplesReturn.uiTabBarController
            }
        }
        return (annotationReturn, uiTabBarController)
    }
    
    
    //
    // Extract the those dictionaries from the Array
    //
    func extractArrayOfDictionary(arrayToExtract arrayToExtract: [Dictionary<String, AnyObject>], uiTabBarController: OTMTabBarController) -> (annotationArrayReturn: [MKPointAnnotation], uiTabBarController: OTMTabBarController) {
        
        var annotationArrayReturn: [MKPointAnnotation] = [MKPointAnnotation]()
        if (arrayToExtract.count > 0) {
            for tempJsonUD in arrayToExtract {
                let firstName: String = tempJsonUD["firstName"] as! String
                let lastName: String = tempJsonUD["lastName"] as! String
                let urlStr: String = tempJsonUD["mediaUrl"] as! String
                let latitude: Double = tempJsonUD["latitude"] as! Double
                let longitude: Double = tempJsonUD["longitude"] as! Double
                let updatedAt: String = tempJsonUD["updatedAt"] as! String
                
                let tempAnnotation: MKPointAnnotation = populateUserData(firstName: firstName, lastName: lastName, urlAsString: urlStr, latitude: latitude, longitude: longitude)
                annotationArrayReturn.append(tempAnnotation)
                
                var tempUD: UserData = UserData(objectId: tempJsonUD["objectId"] as! String, uniqueKey: tempJsonUD["uniqueKey"] as! String, firstName: firstName, lastName: lastName, mapString: tempJsonUD["mapString"] as! String, mediaUrl: urlStr, latitude: latitude, longitude: longitude, createdAt: tempJsonUD["createdAt"] as! String, updatedAt: updatedAt, userLocation: tempAnnotation)
                
                if (tempUD.uniqueKey == uiTabBarController.udacityKey) {
                    uiTabBarController.localUserData = tempUD
                }
                
                if let _ = uiTabBarController.userDataDic[updatedAt] {
                    tempUD.updatedAt = "\(updatedAt)\("_")"
                }
                uiTabBarController.userDataDic[updatedAt] = tempUD
                
            }
        }
        return (annotationArrayReturn, uiTabBarController)
    }
    
    
    //
    // Function that will populate the MKAnnotations and Locations to display in the map
    //
    func populateUserData(firstName firstName: String, lastName: String, urlAsString: String, latitude: Double, longitude: Double) -> MKPointAnnotation {
        let fullName: String = "\(firstName) \(lastName)"
        let tempMKPointAnnotation: MKPointAnnotation = createMkPointAnnotation(fullName: fullName, urlStr: urlAsString, latitude: latitude, longitude: longitude)
        return tempMKPointAnnotation
    }
    
    
    //
    // Create the Point Annotation and return it
    //
    func createMkPointAnnotation(fullName fullName: String, urlStr: String, latitude: Double, longitude: Double) -> MKPointAnnotation {
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let objectAnnotation: MKPointAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = fullName
        objectAnnotation.subtitle = urlStr
        return objectAnnotation
    }
    
    
    //
    // Set local User data when the user still doesn't have added any address
    //
    func createLocalUserData(userDataDictionary userDataDictionary: Dictionary<String, AnyObject>, objectId: String, udacityKey: String, latDouble: Double, lonDouble: Double, pointInformation: MKPointAnnotation) -> UserData {
        let fullUserData: Dictionary<String, AnyObject> = userDataDictionary[OTMClient.ConstantsUdacity.USER] as! Dictionary<String, AnyObject>
        let tempFirstName: String = fullUserData[OTMClient.ConstantsData.firstNameUD] as! String
        let tempLstName:String = fullUserData[OTMClient.ConstantsData.lastNameUD] as! String
        
        
        let tempUserData: UserData = UserData(objectId: objectId, uniqueKey: udacityKey, firstName: tempFirstName, lastName: tempLstName, mapString: OTMClient.ConstantsGeneral.EMPTY_STR, mediaUrl: OTMClient.ConstantsGeneral.EMPTY_STR, latitude: latDouble, longitude: lonDouble, createdAt: OTMClient.ConstantsGeneral.EMPTY_STR, updatedAt: OTMClient.ConstantsGeneral.EMPTY_STR, userLocation: pointInformation)
        return tempUserData
    }
    
    
    //
    // Set new local for local user
    //
    func extractDataFromPUTUserResponse(putDataResponse putDataResponse: Dictionary<String, AnyObject>) -> (tempAction: String, tempObjectId: String, typeAction: String) {
        var tempAction: String!
        var typeAction: String!
        var tempObjectId: String!
        
        if let tempCreateAt: String = putDataResponse[OTMClient.ConstantsData.createdAt] as? String {
            tempAction = tempCreateAt
            typeAction = OTMClient.ConstantsData.createdAt
            tempObjectId = putDataResponse[OTMClient.ConstantsData.objectId] as! String
        } else if let tempUpdateAt: String = putDataResponse[OTMClient.ConstantsData.updatedAt] as? String{
            tempAction = tempUpdateAt
            typeAction = OTMClient.ConstantsData.updatedAt
            tempObjectId = OTMClient.ConstantsGeneral.EMPTY_STR
        }
        return (tempAction, tempObjectId, typeAction)
    }
    
    
    //
    // Add location to localUserData var
    //
    func addLocationToLocalUserData(userData userData: UserData, stringPlace: String, mediaUrl: String, latitude: Double, longitude: Double) -> UserData {
        let tempUserData: UserData = UserData(objectId: userData.objectId!, uniqueKey: userData.uniqueKey!, firstName: userData.firstName!, lastName: userData.lastName!, mapString: stringPlace, mediaUrl: mediaUrl, latitude: latitude, longitude: longitude, createdAt: userData.createdAt, updatedAt: userData.updatedAt, userLocation: userData.userLocation)
        return tempUserData
    }
    
    
    //
    // Check if the url contains or not the http to add it if it doesn't have it.
    //
    func checkUrlToCall(stringUrl stringUrl: String) -> String {
        var stringUrlToReturn: String!
        if (stringUrl.containsString(OTMClient.ConstantsRequest.HTTP_START_WITH)) {
            stringUrlToReturn = stringUrl
        } else {
            stringUrlToReturn =  "http://\(stringUrl)"
        }
        return stringUrlToReturn
    }
    
    
    //
    // Assembly a new UserData struct and set it to the
    // parent class OTMTabBarController.localUserData and also into the dictionary
    //
    func addPUTResponseToUserData(uiTabBarController uiTabBarController: OTMTabBarController, mediaUrl: String, address: String, latitude: Double, longitude: Double, response: Dictionary<String, AnyObject>) -> OTMTabBarController {
        let utils: Utils = Utils()
        let putUserResponse = utils.extractDataFromPUTUserResponse(putDataResponse: response)
        let tempUD: UserData = uiTabBarController.localUserData
        let tempFullName: String = "\(tempUD.firstName) \(tempUD.lastName)"
        let tempAnnotation: MKPointAnnotation = utils.createMkPointAnnotation(fullName: tempFullName, urlStr: mediaUrl, latitude: latitude, longitude: longitude)
        
        var tempCreateAt: String = OTMClient.ConstantsGeneral.EMPTY_STR
        var tempUpdatedAt: String = OTMClient.ConstantsGeneral.EMPTY_STR
        var tempObjecId: String = OTMClient.ConstantsGeneral.EMPTY_STR
        
        if (putUserResponse.typeAction == OTMClient.ConstantsData.createdAt) {
            tempCreateAt = putUserResponse.tempAction
            tempUpdatedAt = putUserResponse.tempAction
            tempObjecId = putUserResponse.tempObjectId
        } else {
            tempCreateAt = uiTabBarController.localUserData.createdAt
            tempUpdatedAt = putUserResponse.tempAction
            tempObjecId = uiTabBarController.localUserData.objectId
        }
        
        var tempUserData: UserData = UserData(objectId: tempObjecId, uniqueKey: tempUD.uniqueKey!, firstName: tempUD.firstName!, lastName: tempUD.lastName, mapString: address, mediaUrl: mediaUrl, latitude: latitude, longitude: longitude, createdAt: tempCreateAt, updatedAt: tempUpdatedAt, userLocation: tempAnnotation)
        
        // To don't have duplicates as the mandatory sort for data in the project is with updateAt field, ideally we shouldn't even sort it
        // as by API documentation the returned data should already come ordered, via url parameter order.
        if let _ = uiTabBarController.userDataDic[tempUpdatedAt] {
            tempUserData.updatedAt = "\(tempUserData.updatedAt)\("_")"
        }
        uiTabBarController.userDataDic[tempUserData.updatedAt] = tempUserData
        
        if (tempUserData.uniqueKey == uiTabBarController.udacityKey) {
            uiTabBarController.localUserData = tempUserData
        }
        return uiTabBarController
        
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
        let empty: String = ""
        var urlForChange: String = OTMClient.ConstantsParse.PARSE_STUDENT_LOCATION_URL
        if (limitP != empty && skipP != empty) {
            urlForChange += "?limit=\(limitP!)&skip=\(skipP!)&order=\(orderP!)"
        } else if (limitP != empty && skipP == empty) {
            urlForChange += "?limit=\(limitP!)&order=\(orderP!)"
        } else if (limitP == empty && skipP == empty) {
            urlForChange += "?order=\(orderP!)"
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
            var tempDictionary: [String: AnyObject] = OTMClient.ConstantsUdacity.UDACITY_LOGIN_JSON
            var udacityTemp: [String: AnyObject] = (tempDictionary[OTMClient.ConstantsUdacity.UDACITY]! as? [String: AnyObject])!
            udacityTemp[OTMClient.ConstantsUdacity.USERNAME] = userName
            udacityTemp[OTMClient.ConstantsUdacity.PASSWORD] = password
            tempDictionary[OTMClient.ConstantsUdacity.UDACITY] = udacityTemp
            
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
    
    
    //
    // Delete those Udacity cookies, received when logged in
    //
    func deleteCookies() {
        let cookieStorage: NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = cookieStorage.cookies as [NSHTTPCookie]?
        for cookie in cookies! {
            NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
        }
    }
    
    
    //
    // Build error message
    //
    func buildErrorMessage(error: NSError)->NSData {
        let dataReadyToReturn: NSData = ("{\"errorMessage\": \"" + error.description + "\"}").dataUsingEncoding(NSUTF8StringEncoding)!
        return dataReadyToReturn
    }
    
    
    //
    // Success login helper,
    // Stores key and id in AppDelegate to use for sub-sequent requests
    //
    func successLoginResponse(responseDictionary: Dictionary<String, AnyObject>, otmTabBarController: OTMTabBarController)-> (isSuccess:Bool, otmTabBarController: OTMTabBarController) {
        var isSuccess:Bool = false
        otmTabBarController.loggedOnUdacity = true
        let account: Dictionary<String, AnyObject> = responseDictionary[OTMClient.ConstantsUdacity.ACCOUNT] as! Dictionary<String, AnyObject>
        
        otmTabBarController.udacityKey = account[OTMClient.ConstantsUdacity.ACCOUNT_KEY] as! String
        
        let session: Dictionary<String, AnyObject> = responseDictionary[OTMClient.ConstantsUdacity.SESSION] as! Dictionary<String, AnyObject>
        
        otmTabBarController.udacitySessionId = session[OTMClient.ConstantsUdacity.SESSION_ID] as! String
        
        if (otmTabBarController.udacityKey != OTMClient.ConstantsGeneral.EMPTY_STR && otmTabBarController.udacitySessionId != OTMClient.ConstantsGeneral.EMPTY_STR) {
            isSuccess = true
        }
        return (isSuccess, otmTabBarController)
    }

}
