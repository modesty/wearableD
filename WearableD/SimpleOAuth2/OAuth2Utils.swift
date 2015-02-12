//
//  Oauth2Utils.swift
//  WearableD
//
//  Created by Zhang, Modesty on 2/11/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import Foundation

struct OAuth2Utils {
    static func authUri() -> String {
        var queryString = "response_type=code&client_id=\(OAuth2Credentials.clientID)&state=\(OAuth2Credentials.state)&redirect_uri=\(OAuth2Credentials.redirectURL)&scope=\(OAuth2Credentials.scope)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        return "\(OAuth2Credentials.authorizeURL)?\(queryString)"
    }
    
    static func exchangeHeader() -> (String, String) {
        var authData = "\(OAuth2Credentials.clientID):\(OAuth2Credentials.clientSecret)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var headerValue = authData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
        return ("Authorization", "Basic \(headerValue)")
    }
    
    static func exchangeBody(authCode: String) -> NSData? {
        return "grant_type=authorization_code&redirect_uri=\(OAuth2Credentials.redirectURL)&code=\(authCode)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    }
    
    static func refreshTokenBody(refreshToken: String) -> NSData? {
        return "grant_type=refresh_token&refresh_token=\(refreshToken)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    }
    
    static let oAuth2Keys = [
        "accessToken": "oAuth2AccessToken",
        "refreshToken": "oAuth2RefreshToken",
        "expiresIn": "oAuth2ExpiresIn",
        "creationDate": "oAuth2CreationDate"
    ]
    
    static func cleanUpKeyChainTokens() {
        for (key, val) in OAuth2Utils.oAuth2Keys {
            KeychainService.deleteAccountItems(val)
        }
    }
    
    static func cacheAuthResults(access_token: String?, refresh_token: String?, expires_in: NSNumber?) -> String {
        var result:String = String()

        // Store the required info for future token refresh in the Keychain.
        if let accessToken = access_token {
            result = accessToken
            
            if OAuth2Credentials.tokenCache {
                
                KeychainService.storeStringToKeychain(accessToken, service: OAuth2Utils.oAuth2Keys["accessToken"]!)
                
                if let refreshToken = refresh_token {
                    KeychainService.storeStringToKeychain(refreshToken, service: OAuth2Utils.oAuth2Keys["refreshToken"]!)
                }
                
                if let expiresIn = expires_in {
                    KeychainService.storeStringToKeychain(expiresIn.stringValue, service: OAuth2Utils.oAuth2Keys["expiresIn"]!)
                }
                
                let date:NSTimeInterval = NSDate().timeIntervalSince1970
                KeychainService.storeStringToKeychain(NSString(format: "%f", date), service: OAuth2Utils.oAuth2Keys["creationDate"]!)
            }
        }
        
        return result
    }
    
    static func retrieveAccessTokenFromKeychain() -> String? {
        return KeychainService.retrieveStringFromKeychain(OAuth2Utils.oAuth2Keys["accessToken"]!)
    }
    
    static func retrieveRefreshTokenFromKeychain() -> String? {
        return KeychainService.retrieveStringFromKeychain(OAuth2Utils.oAuth2Keys["refreshToken"]!)
    }
    
    // Checks if the token that is stored in the keychain is expired
    static func isAccessTokenExpired() -> Bool {
        var isTokenExpired: Bool = true
        
        let optionalExpiresIn: NSString? = KeychainService.retrieveStringFromKeychain(OAuth2Utils.oAuth2Keys["expiresIn"]!)
        
        if let expiresInValue = optionalExpiresIn {
            let expiresTimeInterval:NSTimeInterval = expiresInValue.doubleValue
            
            let optionalCreationDate:NSString? = KeychainService.retrieveStringFromKeychain(OAuth2Utils.oAuth2Keys["creationDate"]!)
            
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
}