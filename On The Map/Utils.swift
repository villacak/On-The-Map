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
                let tempUD: UserData = UserData(objectId: tempJsonUD["objectId"] as! String, uniqueKey: tempJsonUD["uniqueKey"] as! String, firstName: tempJsonUD["firstName"] as! String, lastName: tempJsonUD["lastName"] as! String, mapString: tempJsonUD["mapString"] as! String, mediaUrl: tempJsonUD["mediaUrl"] as! String, latitude: tempJsonUD["latitude"] as! Double, longitude: tempJsonUD["longitude"] as! Double, createdAt: tempJsonUD["createdAt"] as! String, updatedAt: tempJsonUD["updatedAt"] as! String, userLocation: MKPointAnnotation())
                if (tempUD.uniqueKey == uiTabBarController.udacityKey) {
                    uiTabBarController.localUserData = tempUD
                }
                annotationArrayReturn.append(populateUserData(userData: tempUD))
            }
        }
        return (annotationArrayReturn, uiTabBarController)
    }
    
    
    //
    // Function that will populate the MKAnnotations and Locations to display in the map
    //
    func populateUserData(userData userData: UserData) -> MKPointAnnotation {
        let fullName: String = "\(userData.firstName) \(userData.lastName)"
        let tempMKPointAnnotation: MKPointAnnotation = createMkPointAnnotation(fullName: fullName, urlStr: userData.mediaUrl, latitude: userData.latitude, longitude: userData.longitude)
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
}
