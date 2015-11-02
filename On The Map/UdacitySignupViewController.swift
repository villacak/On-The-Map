//
//  UdacitySignupViewController.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/3/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit


class UdacitySignupViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var url: NSURL = NSURL(string: OTMClient.ConstantsUdacity.UDACITY_SIGN_UP)!
    var request: NSURLRequest!
    var otmTabBarController: OTMTabBarController!
    
    
    //
    // Called when view has been loaded
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        otmTabBarController = tabBarController as! OTMTabBarController
        
        myWebView.delegate = self
        
        navigationItem.title = "Udacity Mobile Login"

        request = NSURLRequest(URL: url)
        myWebView.loadRequest(request)
    }
    
    
    //
    // Called when view will apper
    //
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
        otmTabBarController?.tabBar.hidden = true
        if request != nil {
            self.myWebView.loadRequest(request!)
        }
    }
    
    
    //
    // Called when view has started to load
    //
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    
    //
    // Called when view has finished to load
    //
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    
    //
    // Refresh button
    //
    @IBAction func refreshAction(sender: AnyObject) {
        myWebView.reload()
    }
    
}
