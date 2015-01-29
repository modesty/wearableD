//
//  BLEIDs.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/9/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BLESequence : String {
    case None="None", Init = "Init", Working="Working", Ready="Ready",
    Token1="Token1",
    Token2="Token2",
    Token3="Token3",
    Token4="Token4",
    Token5="Token5",
    Token6="Token6",
    Error="Error", End="End"
}

struct BLEIDs {
    static let wctService = CBUUID(string: "46ADCE30-8807-46C6-B91B-EDDFE6F4A1B0")
    static let wctCharacteristic = CBUUID(string: "E0513B78-7DFB-4814-8A00-8DB22EC7AF10")
    
    static func getSequenceData(rawString: String) -> NSData? {
        return rawString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    }
    
    static func randomStringWithLength (len : Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    static let ctHost = "https://consumertranscript-e2e.api.intuit.com"
    static func getCTTransId() -> String {
        return "ion-swift-wearable-\(BLEIDs.randomStringWithLength(4))"
    }
}

