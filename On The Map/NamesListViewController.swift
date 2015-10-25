//
//  NamesListViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/25/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit

class NamesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var postingButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    var otmTabBarController: OTMTabBarController!
    var keys: [String]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        otmTabBarController = tabBarController as! OTMTabBarController
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
        keys = Array(otmTabBarController.userDataDic.keys)
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tempDic: Int = otmTabBarController.userDataDic.count
        
        return tempDic
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let keyForGetFromDictionary: String = keys[indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath)
        let userDataTemp: UserData = otmTabBarController.userDataDic[keyForGetFromDictionary]!
        cell.textLabel?.text = "\(userDataTemp.firstName) \(userDataTemp.lastName)"
        return cell
    }
    
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let keyForGetFromDictionary: String = keys[indexPath.row]
        let userDataTemp: UserData = otmTabBarController.userDataDic[keyForGetFromDictionary]!
        
        if userDataTemp.mediaUrl == OTMClient.ConstantsGeneral.EMPTY_STR {
            Dialog().okDismissAlert(titleStr: OTMClient.ConstantsMessages.ERROR_TITLE, messageStr: OTMClient.ConstantsMessages.NO_URL_DEFINED, controller: self)
        } else {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: userDataTemp.mediaUrl)!)
        }
    }
  
}
