//
//  OAuth2FlowViewController.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/28/15.
//  Based on https://github.com/crousselle/SwiftOAuth2/blob/master/Classes/CRAuthenticationViewController.swift
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import Foundation
import UIKit

class OAuth2FlowViewController: UIViewController, UIWebViewDelegate {
    var webView: UIWebView?
    var spinnerView: UIActivityIndicatorView?
    
    var successCallback : ((code:String)-> Void)?
    var failureCallback : ((error:NSError) -> Void)?
    
    var isRetrievingAuthCode : Bool? = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(successCallback:((code:String)-> Void), failureCallback:((error:NSError) -> Void)) {
        
        super.init()
        
        self.successCallback = successCallback
        self.failureCallback = failureCallback
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = "Login"
        
        self.webView = UIWebView(frame: self.view.bounds);
        self.spinnerView = UIActivityIndicatorView(frame: self.view.bounds)
        
        if let bindCheck = self.webView {
            self.webView!.backgroundColor = UIColor.clearColor()
            self.webView!.scalesPageToFit = true
            self.webView!.delegate = self
            self.view.addSubview(self.webView!)
            
            self.spinnerView!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            self.spinnerView!.hidesWhenStopped = true
            self.spinnerView!.color = UIColor.darkTextColor()
            self.spinnerView!.center = self.view.center;
            self.spinnerView!.startAnimating()
            
            self.view.addSubview(self.spinnerView!)
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("cancelAction"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let urlRequest : NSURLRequest = NSURLRequest(URL: NSURL(string: OAuth2Utils.authUri())!)
        self.webView!.loadRequest(urlRequest)
    }
    
    
    func cancelAction() {
//        self.dismissViewControllerAnimated(true, completion: {
            self.failureCallback!(error: NSError(domain: "Authentication cancelled", code: 409, userInfo: nil))
//        })
    }
    
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
        let url : NSString = request.URL.absoluteString!
        
        self.isRetrievingAuthCode = url.hasPrefix(OAuth2Credentials.redirectURL)
        
        if (self.isRetrievingAuthCode!) {
            if (url.rangeOfString("error").location != NSNotFound) {
                let error:NSError = NSError(domain:"SimpleOAuth2", code:0, userInfo: nil)
                self.failureCallback!(error:error)
            }
            else {
                let optionnalState:String? = self.extractParameterFromUrl("state", url: url)
                
                if let state = optionnalState {
                    if (state == OAuth2Credentials.state) {
                        let optionnalCode:String? = self.extractParameterFromUrl("code", url: url)
                        if let code = optionnalCode {
                            self.successCallback!(code:code)
                        }
                        else {
                            self.failureCallback!(error: NSError(domain: "Authentication failed: missing authorization code", code: 409, userInfo: nil))
                        }
                    }
                    else {
                        self.failureCallback!(error: NSError(domain: "Authentication failed: not recognized state", code: 409, userInfo: nil))
                    }
                }
                else {
                    self.failureCallback!(error: NSError(domain: "Authentication failed:  missing state", code: 409, userInfo: nil))
                }
                
                return false
            }
        }

        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.spinnerView!.stopAnimating()
    }
    
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        if (!self.isRetrievingAuthCode!) {
            self.failureCallback!(error: error)
        }
    }
    
    
    func extractParameterFromUrl(parameterName:NSString, url:NSString) -> String? {
        
        if(url.rangeOfString("?").location == NSNotFound) {
            return nil
        }
        
        if let urlString: String = url.componentsSeparatedByString("?")[1] as? String {
            var dict = Dictionary <String, String>()
            
            for param in urlString.componentsSeparatedByString("&") {
                var array = Array <AnyObject>()
                array = param.componentsSeparatedByString("=")
                let name:String = array[0] as String
                let value:String = array[1] as String
                
                dict[name] = value
            }
            if let result = dict[parameterName] {
                return result
            }
        }
        return nil
    }

}
