//
//  OTMTabBarController.swift
//  On The Map
//
//  Class extending UITabBarController, to share some variables
//  across tab, to redice the amount of controll passing and receiving data
//  at each segue
//
//  Created by Klaus Villaca on 10/6/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import MapKit

class OTMTabBarController: UITabBarController {
    
    var loggedOnUdacity: Bool!
    var udacityKey: String = OTMClient.ConstantsGeneral.EMPTY_STR
    var udacitySessionId: String = OTMClient.ConstantsGeneral.EMPTY_STR
    var udacityUserId: String = OTMClient.ConstantsGeneral.EMPTY_STR
    var localUserData: UserData!
    var mapPoints: [MKPointAnnotation] = [MKPointAnnotation]()
    var appDelegate: AppDelegate!

    
    //
    //  Load data for refresh
    //
    func loadData(numberToLoad numberToLoad: String, cacheToPaginate: String, orderListBy: OTMServicesNameEnum, completionHandler: (result: Bool?, error: NSError?) -> Void) {
        OTMClient.sharedInstance().parseGETStudentLocations(limit: numberToLoad, skip: cacheToPaginate, order: orderListBy){
            (success, errorString)  in
            var responseLoadMapDataAsNSDictinory: Dictionary<String, AnyObject>!
            if (success != nil) {
                responseLoadMapDataAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                if ((responseLoadMapDataAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let message: String = OTMClient.sharedInstance().parseErrorReturned(responseLoadMapDataAsNSDictinory)
                    completionHandler(result: false, error: NSError(domain: OTMClient.ConstantsMessages.LOADING_DATA_FAILED, code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
                } else {
                    let utils: Utils = Utils()
                    
                    let tempTuples = utils.populateLocationList(mapData: responseLoadMapDataAsNSDictinory, uiTabBarController: self)
                    self.mapPoints = tempTuples.annotationReturn
                    self.localUserData = tempTuples.uiTabBarController.localUserData
                    completionHandler(result: true, error: nil)
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                completionHandler(result: false, error: NSError(domain: OTMClient.ConstantsMessages.LOADING_DATA_FAILED, code: 0, userInfo: [NSLocalizedDescriptionKey: (errorString?.description)!]))
            }
        }
    }
    
    
    //
    // Logout
    //
    func logout(completionHandler: (result: Bool?, error: NSError?) -> Void) {
        OTMClient.sharedInstance().udacityPOSTLogout() {
            (success, errorString)  in

            var responseLogoutAsNSDictinory: Dictionary<String, AnyObject>!
            if (success != nil) {
                responseLogoutAsNSDictinory = (success as! NSDictionary) as! Dictionary<String, AnyObject>
                
                // Check if the response contains any error or not
                if ((responseLogoutAsNSDictinory.indexForKey(OTMClient.ConstantsUdacity.ERROR)) != nil) {
                    let message: String = OTMClient.sharedInstance().parseErrorReturned(responseLogoutAsNSDictinory)
                    completionHandler(result: false, error: NSError(domain: OTMClient.ConstantsMessages.LOGIN_FAILED, code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
                } else {
                    completionHandler(result: true, error: nil)
                }
            } else {
                // If success returns nil then it's necessary display an alert to the user
                completionHandler(result: false, error: NSError(domain: OTMClient.ConstantsMessages.LOGIN_FAILED, code: 0, userInfo: [NSLocalizedDescriptionKey: (errorString?.description)!]))
            }
        }

    }
    
    //
    // To have the same instance been shared.
    //
    class func sharedInstance() -> OTMTabBarController {
        struct Singleton {
            static var sharedInstance = OTMTabBarController()
        }
        return Singleton.sharedInstance
    }


}
