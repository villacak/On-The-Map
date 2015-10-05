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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myWebView.delegate = self
        
        self.navigationItem.title = "Udacity Mobile Login"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAuth")
        
        request = NSURLRequest(URL: url)
        myWebView.loadRequest(request)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if request != nil {
            self.myWebView.loadRequest(request!)
        }
    }
    
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    
    // MARK: - UIWebViewDelegate
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
        
        if(webView.request!.URL!.absoluteString == OTMClient.ConstantsUdacity.UDACITY_SIGN_UP) {
            self.dismissViewControllerAnimated(true, completion: {})
        }
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func refreshAction(sender: AnyObject) {
        myWebView.reload()
    }
    
}
