//
//  OTMServiceCaller.swift
//  On The Map
//
//  Created by Klaus Villaca on 11/9/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import MapKit

class OTMServiceCaller: NSObject {
    
    
    //
    // Login button
    //
    func login(userName userName: String, password: String, var domainUtils: OTMDomainUtils, completionHandler: (result: OTMDomainUtils?, error: String?) -> Void) {
        OTMClient.sharedInstance().udacityPOSTLogin(userName: userName, password: password) {
            (success, errorString)  in
            
            var isSuccess: Bool = false
            if (success != nil) {
                // Convert the NSDictionary that is received as AnyObject to Dictionary
                let responseAsNSDictinory: Dictionary<String, AnyObject> = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if let errorString = errorString {
                    completionHandler(result: nil, error: errorString)
                } else {
                    let utils: Utils = Utils()
                    let successResponse = utils.successLoginResponse(responseAsNSDictinory, domainUtils: domainUtils)
                    isSuccess = successResponse.isSuccess
                    if (isSuccess) {
                        domainUtils = successResponse.domainUtils
                        completionHandler(result: domainUtils, error: nil)
                    } else {
                        completionHandler(result: nil, error: errorString)
                    }
                }
            } else {
                // If not success returns nil then it's necessary display an alert to the user
                completionHandler(result: nil, error: errorString)
            }
        }
    }
    
    //
    // Load the Udacity User Data
    //
    func loadUserData(domainUtils domainUtils: OTMDomainUtils, completionHandler: (result: OTMDomainUtils?, error: String?) -> Void) {
        OTMClient.sharedInstance().udacityPOSTGetUserData(udacityId: domainUtils.udacityKey){
            (success, errorString)  in
            var responseLoadUserDataAsNSDictinory: Dictionary<String, AnyObject>!
            if (success != nil) {
                responseLoadUserDataAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if let errorString = errorString {
                    completionHandler(result: nil, error: errorString)
                } else {
                    let tempEmptyMKPointAnnotation: MKPointAnnotation = MKPointAnnotation()
                    let utils: Utils = Utils()
                    domainUtils.localUserData = utils.createLocalUserData(userDataDictionary: responseLoadUserDataAsNSDictinory, objectId: OTMClient.ConstantsGeneral.EMPTY_STR, udacityKey: domainUtils.udacityKey, latDouble: 0, lonDouble: 0, pointInformation: tempEmptyMKPointAnnotation)
                    completionHandler(result: domainUtils, error: nil)
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                completionHandler(result: nil, error: errorString)
            }
        }
    }


    
    
    //
    //  Load data
    //
    func loadData(numberToLoad numberToLoad: String, cacheToPaginate: String, orderListBy: OTMServicesNameEnum, domainUtils: OTMDomainUtils, completionHandler: (result: OTMDomainUtils?, error: String?) -> Void) {
        OTMClient.sharedInstance().parseGETStudentLocations(limit: numberToLoad, skip: cacheToPaginate, order: orderListBy){
            (success, errorString)  in
            var responseLoadMapDataAsNSDictinory: Dictionary<String, AnyObject>!
            if (success != nil) {
                responseLoadMapDataAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                if let errorMessage = errorString  {
                    completionHandler(result: nil, error: errorMessage)
                } else {
                    let utils: Utils = Utils()
                    let tempTuples = utils.populateLocationList(mapData: responseLoadMapDataAsNSDictinory, domainUtils: domainUtils)
                    domainUtils.mapPoints = tempTuples.annotationReturn
                    domainUtils.localUserData = tempTuples.domainUtils.localUserData
                    completionHandler(result: domainUtils, error: nil)
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                completionHandler(result: nil, error: errorString)
            }
        }
    }
    
    
    //
    // Logout
    //
    func logout(completionHandler: (result: Bool?, error: String?) -> Void) {
        OTMClient.sharedInstance().udacityPOSTLogout() {
            (success, errorString)  in
            if (success != nil) {
                // Check if the response contains any error or not
                if let errorMessage = errorString  {
                    completionHandler(result: nil, error: errorMessage)
                } else {
                    completionHandler(result: true, error: nil)
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                completionHandler(result: false, error: errorString)
            }
        }
    }
    
    
    //
    // Post user location for the very first time, then once we have the objectId we just use updateData()
    //
    func putData(var domainUtils domainUtils: OTMDomainUtils, stringPlace: String, mediaURL: String, latitude: Double, longitude: Double,completionHandler: (result: OTMDomainUtils?, error: String?) -> Void) {
        var responseAsNSDictinory: Dictionary<String, AnyObject>!
        domainUtils.localUserData.mapString = stringPlace
        domainUtils.localUserData.mediaURL = mediaURL
        domainUtils.localUserData.latitude = latitude
        domainUtils.localUserData.longitude = longitude
        
        OTMClient.sharedInstance().putPOSTStudentLocation(userData: domainUtils.localUserData){
            (success, errorString)  in
            if (success != nil) {
                responseAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if let errorMessage = errorString  {
                    completionHandler(result: nil, error: errorMessage)
                } else {
                    let utils: Utils = Utils()
                    let extractedData = utils.extractDataFromPUTUserResponse(putDataResponse: responseAsNSDictinory)
                    domainUtils.localUserData.objectId = extractedData.tempObjectId
                    domainUtils.localUserData.createdAt = extractedData.tempAction
                    domainUtils.localUserData.updatedAt = extractedData.tempAction
                    
                    domainUtils = utils.addPUTResponseToUserData(domainUtils: domainUtils, mediaURL: mediaURL, address: stringPlace, latitude: latitude, longitude: longitude, response: responseAsNSDictinory)
                    completionHandler(result: domainUtils, error: nil)
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                completionHandler(result: nil, error: errorString)
            }
        }
    }
    
    
    //
    // Function called always that the local user already has a objectId form parse
    //
    //
    // Post user location for the very first time, then once we have the objectId we just use updateData()
    //
    func updateData(var domainUtils domainUtils: OTMDomainUtils, stringPlace: String, mediaURL: String, latitude: Double, longitude: Double,completionHandler: (result: OTMDomainUtils?, error: String?) -> Void) {
        var responseAsNSDictinory: Dictionary<String, AnyObject>!
        domainUtils.localUserData.mapString = stringPlace
        domainUtils.localUserData.mediaURL = mediaURL
        domainUtils.localUserData.latitude = latitude
        domainUtils.localUserData.longitude = longitude
        
        OTMClient.sharedInstance().updatingPUTStudentLocation(userData: domainUtils.localUserData){
            (success, errorString)  in
            if (success != nil) {
                responseAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if let errorMessage = errorString  {
                    completionHandler(result: nil, error: errorMessage)
                } else {
                    let utils: Utils = Utils()
                    let extractedData = utils.extractDataFromPUTUserResponse(putDataResponse: responseAsNSDictinory)
                    domainUtils.localUserData.objectId = extractedData.tempObjectId
                    domainUtils.localUserData.updatedAt = extractedData.tempAction
                    
                    domainUtils = utils.addPUTResponseToUserData(domainUtils: domainUtils, mediaURL: mediaURL, address: stringPlace, latitude: latitude, longitude: longitude, response: responseAsNSDictinory)
                    completionHandler(result: domainUtils, error: nil)
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                completionHandler(result: nil, error: errorString)
            }
        }
    }

}
