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
    static let redirectURI = "http://ion.mydev.com/#/code"
    static let clientID = ""
    static let clientSecret = ""
    static let scope = "intuit.cg.turbotax.unleash"
    static let state = "wearableD"
    
    static func authUri() -> String {
        var queryString = "response_type=code&client_id=\(OAuth2Credentials.clientID)&state=\(OAuth2Credentials.state)&redirect_uri=\(OAuth2Credentials.redirectURI)&scope=\(OAuth2Credentials.scope)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
        return "\(OAuth2Credentials.authorizeURL)?\(queryString)"
    }
}

