//
//  Utils.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/28/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class Utils: NSObject {
    
    
    //
    // Populate the pins from the list into the map
    //
    func populateLocationList(mapData mapData: Dictionary<String, AnyObject>) -> [MKPointAnnotation] {
        var annotationReturn: [MKPointAnnotation] = [MKPointAnnotation]()
        let results: [UserData]? = mapData[OTMClient.ConstantsParse.RESULTS] as? [UserData]
        // Populate the map with the list
        if results?.count > 0 {
            for userDataJson in results! {
                print("item value: \(userDataJson)")
                annotationReturn.append(populateUserData(userData: userDataJson))
            }
        }
        return annotationReturn
    }

    
    //
    // Function that will populate the MKAnnotations and Locations to display in the map
    //
    func populateUserData(userData userData: UserData) -> MKPointAnnotation {
        
        let fullName: String = "\(userData.firstName) \(userData.lastName)"
        let utils: Utils = Utils()
        let tempMKPointAnnotation: MKPointAnnotation = utils.createMkPointAnnotation(fullName: fullName, urlStr: OTMClient.ConstantsGeneral.EMPTY_STR, latitude: userData.latitude, longitude: userData.longitude)
        
        print(userData)
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
    // Convert String date to NSDate
    //
    func convertStringToDate(dateAsString dateAsString: String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "US_en")
        formatter.dateFormat = "yyyy-dd-MMTHH:mm:ssZ"
        let date = formatter.dateFromString(dateAsString)
        return date!
    }
    
    
    //
    // Set local User data when the user still doesn't have added any address
    //
    func createLocalUserData(userDataDictionary userDataDictionary: Dictionary<String, AnyObject>, objectId: String, udacityKey: String, latDouble: Double, lonDouble: Double, pointInformation: MKPointAnnotation) -> UserData {
        let fullUserData: Dictionary<String, AnyObject> = userDataDictionary[OTMClient.ConstantsUdacity.USER] as! Dictionary<String, AnyObject>
        let tempFirstName: String = fullUserData[OTMClient.ConstantsData.firstNameUD] as! String
        let tempLstName:String = fullUserData[OTMClient.ConstantsData.lastNameUD] as! String
        
        
        let tempUserData: UserData = UserData(objectId: objectId, uniqueKey: udacityKey, firstName: tempFirstName, lastName: tempLstName, mapString: OTMClient.ConstantsGeneral.EMPTY_STR, mediaUrl: OTMClient.ConstantsGeneral.EMPTY_STR, latitude: latDouble, longitude: lonDouble, createdAt: NSDate(), updatedAt: NSDate(), userLocation: pointInformation)
        return tempUserData
    }
    
    
    //
    // Set new local for local user
    //
    func extractDataFromPUTUserResponse(putDataResponse putDataResponse: Dictionary<String, AnyObject>) -> (tempCreatedAt: NSDate, tempObjectId: String) {
        let tempDicArray: [AnyObject] = putDataResponse as! [AnyObject]
        let tempFistArrayItem: Dictionary<String, String> = tempDicArray[0] as! Dictionary<String, String>
        let tempSecondArrayItem: Dictionary<String, String> = tempDicArray[1] as! Dictionary<String, String>
        let tempStringDate: String = tempFistArrayItem[OTMClient.ConstantsData.createdAt]!
        let tempCreateAt: NSDate = convertStringToDate(dateAsString: tempStringDate)
        let tempObjectId: String = tempSecondArrayItem[OTMClient.ConstantsData.createdAt]!
        return (tempCreateAt, tempObjectId)
    }
    
    

}
