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
    case Init = "Init", Working="Working", Error="Error", Ready="Ready", End="End"
}

struct BLEIDs {
    static let wctService = CBUUID(string: "46ADCE30-8807-46C6-B91B-EDDFE6F4A1B0")
    static let wctCharacteristic = CBUUID(string: "E0513B78-7DFB-4814-8A00-8DB22EC7AF10")
    
    static func getSequenceData(rawString: String) -> NSData? {
        return rawString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    }
}

