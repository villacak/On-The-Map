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
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        otmTabBarController = tabBarController as! OTMTabBarController
        
        myWebView.delegate = self
        
        navigationItem.title = "Udacity Mobile Login"

        request = NSURLRequest(URL: url)
        myWebView.loadRequest(request)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
        otmTabBarController?.tabBar.hidden = true
        if request != nil {
            self.myWebView.loadRequest(request!)
        }
    }
    
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    
    // MARK: - UIWebViewDelegate
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    
    @IBAction func refreshAction(sender: AnyObject) {
        myWebView.reload()
    }
    
}
