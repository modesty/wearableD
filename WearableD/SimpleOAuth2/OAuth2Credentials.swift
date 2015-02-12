//
//  OAuth2Credentials.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/28/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import Foundation

//Get these settings from your OAuth2 provider first

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
}

