//
//  PeripheralViewController.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/28/15.
//  Thanks to https://github.com/crousselle/SwiftOAuth2
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import Foundation
import Security

class KeychainService : NSObject
{
    class var account: String {return "OAuth2Tokens"}
    
    class func deleteAccountItems(service: CFStringRef) -> OSStatus {
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, account],
            forKeys: [kSecClass, kSecAttrService, kSecAttrAccount])
        
        return SecItemDelete(keychainQuery as CFDictionaryRef)
    }
    
    class func storeStringToKeychain(stringToStore:NSString, service:CFStringRef) -> Void {
        
        let data: NSData? = stringToStore.dataUsingEncoding(NSUTF8StringEncoding)
        
        if let optionalData = data {
            var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, account, optionalData],
                forKeys: [kSecClass, kSecAttrService, kSecAttrAccount, kSecValueData])
            
            var status:OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
        }
    }
    
    class func retrieveStringFromKeychain(service: CFStringRef) -> NSString? {
        
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPassword, service, account, kCFBooleanTrue, kSecMatchLimitOne],
            forKeys: [kSecClass, kSecAttrService, kSecAttrAccount, kSecReturnData, kSecMatchLimit])
        
        var dataTypeRef :Unmanaged<AnyObject>?
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        if status == errSecSuccess {
            let opaque = dataTypeRef?.toOpaque()
            var contentsOfKeychain: NSString?
        
            if let op = opaque? {
                let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
            
                contentsOfKeychain = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
            
                if let finalString = contentsOfKeychain {
                    println("retrieved from keychain : " + (service as NSString) + "= " + finalString)
                    return finalString
                }
            }
        }
        
        return nil
    }
 }