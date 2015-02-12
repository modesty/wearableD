//
//  OAuth2Client.swift
//  WearableD
//
//  Created by Ryan Ford on 1/28/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

//
//  CROAuth2Client.swift
//  CROAuth2Client
//

//

import Foundation
import UIKit

public class OAuth2Client : NSObject {

    var sourceViewController:UIViewController?
    
    init (controller : UIViewController) {
        self.sourceViewController = controller
    }
    
    func retrieveAccessToken(token:((accessToken:String?) -> Void)) -> Void {
        var startOver = true
        
        if !OAuth2Credentials.tokenCache {
            OAuth2Utils.cleanUpKeyChainTokens()
        }
        
        // We found a token in the keychain, we need to check if it is not expired
        if let optionalStoredAccessToken = OAuth2Utils.retrieveAccessTokenFromKeychain() {
            if (OAuth2Utils.isAccessTokenExpired()) {
                // Token expired, attempt to refresh it
                if let refreshToken = OAuth2Utils.retrieveRefreshTokenFromKeychain() {
                    self.refreshAccessToken(refreshToken, newToken: token)
                    startOver = false
                }
            }
            else {
                // Token not expired, use it to authenticate future requests.
                token(accessToken: optionalStoredAccessToken)
                startOver = false
            }
        }
            
        if startOver == true {
            // First, let's retrieve the autorization_code by login the user in.
            self.retrieveAuthorizationCode { (authorizationCode) -> Void in
                
                if let optionalAuthCode = authorizationCode {

                    // We have the authorization_code, we now need to exchange it for the accessToken by doind a POST request
                    let url : String = OAuth2Credentials.tokenURL
                    var (authHeaderKey, authHeaderValue) = OAuth2Utils.exchangeHeader()
                    
                    println("received authCode: \(optionalAuthCode)")
                    
                    var request : NSMutableURLRequest = NSMutableURLRequest()
                    request.HTTPMethod = "POST"
                    request.URL = NSURL(string: url)
                    request.addValue(authHeaderValue, forHTTPHeaderField: authHeaderKey)
                    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.HTTPBody = OAuth2Utils.exchangeBody(optionalAuthCode)
                    
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(),
                        completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                            if error != nil {
                                println(error.localizedDescription)
                                 token(accessToken: nil)
                            }
                            else {
                                var json_error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
                                let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: json_error) as? NSDictionary
                                let accessToken:String = self.retrieveAccessTokenFromJSONResponse(jsonResult!)
                                token(accessToken: accessToken)
                            }
                    })//end connection
                }//end optionalAuthCode
                else {
                    token(accessToken: nil)
                }
            }
        }//end else
    }//end function
    
    
    // Retrieves the autorization code by presenting a webView that will let the user login
    private func retrieveAuthorizationCode(authoCode:((authorizationCode:String?) -> Void)) -> Void{
        func success(code:String) -> Void {
            println("OAuth2 authCode = \(code)")
            self.sourceViewController?.dismissViewControllerAnimated(true, completion: {
                authoCode(authorizationCode:code)
            })
            
        }
        
        func failure(error:NSError) -> Void {
            println("ERROR = " + error.description)
            self.sourceViewController?.dismissViewControllerAnimated(true, completion: {
                authoCode(authorizationCode:nil)
            })
        }
        
        var authenticationViewController: OAuth2FlowViewController = OAuth2FlowViewController(successCallback:success, failureCallback:failure)
        var navigationController:UINavigationController = UINavigationController(rootViewController: authenticationViewController)
        
        self.sourceViewController?.presentViewController(navigationController, animated:true, completion:nil)
    }
    
    // Request a new access token with our refresh token
    func refreshAccessToken(refreshToken:String, newToken:((accessToken:String?) -> Void)) -> Void {
        
        println("Need to refresh the token with refreshToken : " + refreshToken)
        
        let url:String = OAuth2Credentials.tokenURL
        var (authHeaderKey, authHeaderValue) = OAuth2Utils.exchangeHeader()
        
        var request : NSMutableURLRequest = NSMutableURLRequest()

        request.HTTPMethod = "POST"
        request.URL = NSURL(string: url)
        request.addValue(authHeaderValue, forHTTPHeaderField: authHeaderKey)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = OAuth2Utils.refreshTokenBody(refreshToken)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(),
            completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if error != nil {
                    println(error.localizedDescription)
                    newToken(accessToken: nil)
                }
                else {
                    var json_error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
                    let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: json_error) as? NSDictionary
                    let accessToken:String = self.retrieveAccessTokenFromJSONResponse(jsonResult!)
                    newToken(accessToken: accessToken)
                }
        })//end connection
    }
    
    // Extract the accessToken from the JSON response that the authentication server returned
    private func retrieveAccessTokenFromJSONResponse(jsonResponse: NSDictionary?) -> String {
        var result:String = String()
        
        if let jsonResult: NSDictionary = jsonResponse {
            
            let optionalAccessToken = jsonResult["access_token"] as? String
            let optionalRefreshToken = jsonResult["refresh_token"] as? String
            let optionalExpiresIn = jsonResult["expires_in"] as? NSNumber
            
            result = OAuth2Utils.cacheAuthResults(optionalAccessToken, refresh_token: optionalRefreshToken, expires_in: optionalExpiresIn)
        }
        
        return result
    }
}