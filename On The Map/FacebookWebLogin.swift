//
//  FacebookWebLogin.swift
//  On The Map
//
//  Created by Klaus Villaca on 10/3/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//
//
//import UIKit

//
// This class isn't been used as Facebook isn't enabled
//class FacebookWebLogin: UIViewController, UIWebViewDelegate {
//
//    
//    @IBOutlet weak var webView: UIWebView!
//    
//    var urlRequest: NSURLRequest? = nil
//    var requestToken: String? = nil
//    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        webView.delegate = self
//        
//        self.navigationItem.title = "Facebook Mobile Login"
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelAuth")
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        
//        super.viewWillAppear(animated)
//        
//        if urlRequest != nil {
//            self.webView.loadRequest(urlRequest!)
//        }
//    }
//    
//    // MARK: - UIWebViewDelegate
//    
//    func webViewDidFinishLoad(webView: UIWebView) {
//        
//        if(webView.request!.URL!.absoluteString == "<would have the facebook login url>") {
//            
//            self.dismissViewControllerAnimated(true, completion: { () -> Void in
//                self.completionHandler!(success: true, errorString: nil)
//            })
//        }
//    }
//    
//    func cancelAuth() {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//
//}
