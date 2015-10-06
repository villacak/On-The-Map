//
//  ActivityIndicatorView.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/5/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit

// Copied part from stackoverflow
// http://stackoverflow.com/questions/28785715/how-to-display-an-activity-indicator-with-text-on-ios-8-with-swift
//
// The idea is have a processing modal showing to the user while the request is processed.
class ActivityIndicatorView: NSObject {

    var view: UIView!
    
    var activityIndicator: UIActivityIndicatorView!
    
    var title: String!
    
    init(title: String, center: CGPoint, width: CGFloat = 200.0, height: CGFloat = 50.0)
    {
        self.title = title
        
        let x = center.x - width/2.0
        let y = center.y - height/2.0
        
        self.view = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        self.view.backgroundColor = UIColor(red: 255.0/255.0, green: 204.0/255.0, blue: 51.0/255.0, alpha: 0.5)
        self.view.layer.cornerRadius = 10
        
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.activityIndicator.color = UIColor.blackColor()
        self.activityIndicator.hidesWhenStopped = false
        
        let titleLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        titleLabel.text = title
        titleLabel.textColor = UIColor.blackColor()
        
        self.view.addSubview(self.activityIndicator)
        self.view.addSubview(titleLabel)
    }
    
    func getViewActivityIndicator() -> UIView
    {
        return self.view
    }
    
    func hideActivityIndicator() {
        self.view.hidden = true
    }
   
    
    func showActivityIndicator() {
        self.view.hidden = false
    }
    
    
    func startAnimating()
    {
        self.activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func stopAnimating()
    {
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        self.view.removeFromSuperview()
    }

}
