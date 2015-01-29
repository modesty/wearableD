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




class OAuth2Client : NSObject {
    
    var baseURL = OAuth2Credentials.baseURL
    var sourceViewController:UIViewController?
    
    private let oAuth2AccessToken  = "oAuth2AccessToken"
    private let oAuth2RefreshToken  = "oAuth2RefreshToken"
    private let oAuth2ExpiresIn  = "oAuth2ExpiresIn"
    private let oAuth2CreationDate = "oAuth2CreationDate"
    
    private let tokenUrl = OAuth2Credentials.tokenURL
    private let clientId = OAuth2Credentials.clientID
    private let clientSecret = OAuth2Credentials.clientSecret
    private let redirectUrl = OAuth2Credentials.redirectURI

    
    init (controller : UIViewController) {
        self.sourceViewController = controller
    }
    
    func retrieveAuthToken(token:((accessToken:String?) -> Void)) -> Void {
        
        // We found a token in the keychain, we need to check if it is not expired
        if let optionalStoredAccessToken: String? = self.retrieveAccessTokenFromKeychain() {
            
            // Token expired, attempt to refresh it
            if (self.isAccessTokenExpired()) {
                if let refreshToken = self.retrieveRefreshTokenFromKeychain() {
                    self.refreshToken(refreshToken, newToken: token)
                }
            }
                // Token not expired, use it to authenticate future requests.
            else {
                token(accessToken: optionalStoredAccessToken)
            }
            
        }
        else {
            // First, let's retrieve the autorization_code by login the user in.
            self.retrieveAuthorizationCode { (authorizationCode) -> Void in
                
                if let optionalAuthCode = authorizationCode {
                    // We have the authorization_code, we now need to exchange it for the accessToken by doind a POST request
                    let url : String = OAuth2Credentials.exchangeUri(optionalAuthCode)
                    
                    // Trigger the POST request
                    //add header
                    var request : NSMutableURLRequest = NSMutableURLRequest()
                    request.URL = NSURL(string: url)
                    var (authHeaderKey, authHeaderValue) = OAuth2Credentials.exchangeHeader()
                    request.addValue(authHeaderKey, forHTTPHeaderField: authHeaderValue)
                    request.HTTPMethod = "POST"
                    
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
            }
        }//end else

    }//end function
    
    
    
    // Retrieves the autorization code by presenting a webView that will let the user login
    private func retrieveAuthorizationCode(authoCode:((authorizationCode:String?) -> Void)) -> Void{
        
        func success(code:String) -> Void {
            println("SUCCESS AND CODE = " + code)
            self.sourceViewController?.dismissViewControllerAnimated(true, completion: nil)
            authoCode(authorizationCode:code)
        }
        
        func failure(error:NSError) -> Void {
            println("ERROR = " + error.description)
            self.sourceViewController?.dismissViewControllerAnimated(true, completion: nil)
            authoCode(authorizationCode:nil)
        }
        
        var authenticationViewController: OAuth2FlowViewController = OAuth2FlowViewController(successCallback:success, failureCallback:failure)
        var navigationController:UINavigationController = UINavigationController(rootViewController: authenticationViewController)
        
        self.sourceViewController?.presentViewController(navigationController, animated:true, completion:nil)
    }
    
    // Checks if the token that is stored in the keychain is expired
    private func isAccessTokenExpired() -> Bool {
        
        var isTokenExpired: Bool = true
        
        let optionalExpiresIn: NSString? = KeychainService.retrieveStringFromKeychain(self.oAuth2ExpiresIn)
        
        if let expiresInValue = optionalExpiresIn {
            let expiresTimeInterval:NSTimeInterval = expiresInValue.doubleValue
            
            let optionalCreationDate:NSString? = KeychainService.retrieveStringFromKeychain(self.oAuth2CreationDate)
            
            if let creationDate = optionalCreationDate {
                let creationTimeInterval:NSTimeInterval = creationDate.doubleValue
                
                // need to refresh the token
                if (NSDate().timeIntervalSince1970 < creationTimeInterval + expiresTimeInterval) {
                    isTokenExpired = false
                }
            }
        }
        
        return isTokenExpired
    }
    
    private func retrieveAccessTokenFromKeychain() -> String? {
        return KeychainService.retrieveStringFromKeychain(self.oAuth2AccessToken)
    }
    
    private func retrieveRefreshTokenFromKeychain() -> String? {
        return KeychainService.retrieveStringFromKeychain(self.oAuth2RefreshToken)
    }
    
    // Request a new access token with our refresh token
    func refreshToken(refreshToken:String, newToken:((accessToken:String?) -> Void)) -> Void {
        
        println("Need to refresh the token with refreshToken : " + refreshToken)
        
        let url:String = OAuth2Credentials.refreshTokenUri(refreshToken)
        
        
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        var (authHeaderKey, authHeaderValue) = OAuth2Credentials.exchangeHeader()
        request.addValue(authHeaderKey, forHTTPHeaderField: authHeaderValue)
        request.HTTPMethod = "POST"
        
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
            
            let optionalAccessToken : NSString? = jsonResult["access_token"] as? NSString
            let optionalRefreshToken : NSString? = jsonResult["refresh_token"] as? NSString
            let optionalExpiresIn : NSNumber? = jsonResult["expires_in"] as? NSNumber
            
            // Store the required info for future token refresh in the Keychain.
            if let accessToken = optionalAccessToken {
                result = accessToken
                KeychainService.storeStringToKeychain(accessToken, service: self.oAuth2AccessToken)
            }
            if let refreshToken = optionalRefreshToken {
                KeychainService.storeStringToKeychain(refreshToken, service: self.oAuth2RefreshToken)
            }
            if let expiresIn = optionalExpiresIn {
                let string:NSString = "1"
                KeychainService.storeStringToKeychain(string, service: self.oAuth2ExpiresIn)
            }
            
            let date:NSTimeInterval = NSDate().timeIntervalSince1970
            KeychainService.storeStringToKeychain(NSString(format: "%f", date), service: oAuth2CreationDate)
        }
        
        return result
    }
    
    
}