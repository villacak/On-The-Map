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
    func login(userName userName: String, password: String, var uiTabBarController: OTMTabBarController, completionHandler: (result: OTMTabBarController?, error: String?) -> Void) {
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
                    let successResponse = utils.successLoginResponse(responseAsNSDictinory, otmTabBarController: uiTabBarController)
                    isSuccess = successResponse.isSuccess
                    if (isSuccess) {
                        uiTabBarController = successResponse.otmTabBarController
                        completionHandler(result: uiTabBarController, error: nil)
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
    func loadUserData(uiTabBarController uiTabBarController: OTMTabBarController, completionHandler: (result: OTMTabBarController?, error: String?) -> Void) {
        OTMClient.sharedInstance().udacityPOSTGetUserData(udacityId: uiTabBarController.udacityKey){
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
                    uiTabBarController.localUserData = utils.createLocalUserData(userDataDictionary: responseLoadUserDataAsNSDictinory, objectId: OTMClient.ConstantsGeneral.EMPTY_STR, udacityKey: uiTabBarController.udacityKey, latDouble: 0, lonDouble: 0, pointInformation: tempEmptyMKPointAnnotation)
                    completionHandler(result: uiTabBarController, error: nil)
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
    func loadData(numberToLoad numberToLoad: String, cacheToPaginate: String, orderListBy: OTMServicesNameEnum, uiTabBarController: OTMTabBarController, completionHandler: (result: OTMTabBarController?, error: String?) -> Void) {
        OTMClient.sharedInstance().parseGETStudentLocations(limit: numberToLoad, skip: cacheToPaginate, order: orderListBy){
            (success, errorString)  in
            var responseLoadMapDataAsNSDictinory: Dictionary<String, AnyObject>!
            if (success != nil) {
                responseLoadMapDataAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                if let errorMessage = errorString  {
                    completionHandler(result: nil, error: errorMessage)
                } else {
                    let utils: Utils = Utils()
                    let tempTuples = utils.populateLocationList(mapData: responseLoadMapDataAsNSDictinory, uiTabBarController: uiTabBarController)
                    uiTabBarController.mapPoints = tempTuples.annotationReturn
                    uiTabBarController.localUserData = tempTuples.uiTabBarController.localUserData
                    completionHandler(result: uiTabBarController, error: nil)
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
    func putData(var uiTabBarController uiTabBarController: OTMTabBarController, stringPlace: String, mediaURL: String, latitude: Double, longitude: Double,completionHandler: (result: OTMTabBarController?, error: String?) -> Void) {
        var responseAsNSDictinory: Dictionary<String, AnyObject>!
        OTMClient.sharedInstance().putPOSTStudentLocation(userData: uiTabBarController.localUserData){
            (success, errorString)  in
            if (success != nil) {
                responseAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if let errorMessage = errorString  {
                    completionHandler(result: nil, error: errorMessage)
                } else {
                    let utils: Utils = Utils()
                    uiTabBarController = utils.addPUTResponseToUserData(uiTabBarController: uiTabBarController, mediaURL: mediaURL, address: stringPlace, latitude: latitude, longitude: longitude, response: responseAsNSDictinory)
                    completionHandler(result: uiTabBarController, error: nil)
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
    func updateData(var uiTabBarController uiTabBarController: OTMTabBarController, stringPlace: String, mediaURL: String, latitude: Double, longitude: Double,completionHandler: (result: OTMTabBarController?, error: String?) -> Void) {
        var responseAsNSDictinory: Dictionary<String, AnyObject>!
        OTMClient.sharedInstance().updatingPUTStudentLocation(userData: uiTabBarController.localUserData){
            (success, errorString)  in
            if (success != nil) {
                responseAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if let errorMessage = errorString  {
                    completionHandler(result: nil, error: errorMessage)
                } else {
                    let utils: Utils = Utils()
                    uiTabBarController = utils.addPUTResponseToUserData(uiTabBarController: uiTabBarController, mediaURL: mediaURL, address: stringPlace, latitude: latitude, longitude: longitude, response: responseAsNSDictinory)
                    completionHandler(result: uiTabBarController, error: nil)
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                completionHandler(result: nil, error: errorString)
            }
        }
    }

}
