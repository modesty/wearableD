//
//  OAuth2Credentials.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/28/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import Foundation

struct OAuth2Credentials {
    static let baseURL = "https://"
    static let authorizeURL = "https://accounts-e2e.intuit.com/op/v1/ase"
    static let tokenURL = "https://oauth-e2e.platform.intuit.com/oauth2/v1/tokens/bearer"
    static let redirectURL = "http://ion.mydev.com/#/code"
    static let clientID = ""
    static let clientSecret = ""
    static let scope = "intuit.cg.turbotax.unleash"
    static let state = "wearableD"
    static let tokenCache = false
    
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
}

