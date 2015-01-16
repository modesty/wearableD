//
//  BLEPeripheral.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/9/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEPeripheralDelegate {
    func blePeripheralMsgUpdate(textMsg:String!)
    func blePeripheralIsReady()
    func blePeripheralDidSendData()
    func blePeripheralDidStop()
}


class BLEPeripheral: NSObject, CBPeripheralManagerDelegate {
    var wctPeripheral: CBPeripheralManager?
    var wctService: CBMutableService?
    var wctCharacteristic: CBMutableCharacteristic?
    
    var wctSequence: BLESequence
    var wctConnectedCentral: CBCentral?
    
    var delegate: BLEPeripheralDelegate!
    
    // oAuth error or cancel
    var data_error: String
    // oAuth access token
    var data_token: String
    
    override init() {
        self.wctPeripheral = nil
        self.wctService = nil
        self.wctCharacteristic = nil
        
        self.wctSequence = .None
        self.wctConnectedCentral = nil
        
        self.data_error = "OAuth error or cancel"
        self.data_token = "OAuth access token"
        self.delegate = nil
        
        super.init()
    }
    
    
    func openPeripheral(delegate: BLEPeripheralDelegate!) {
        self.delegate = delegate
        self.wctPeripheral = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func startPeripheral() {
        // start advertising with specific service uuid
        self.wctPeripheral!.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [BLEIDs.wctService] ])
    }
    
    func closePeripheral() {
        self.wctConnectedCentral = nil
        self.wctPeripheral!.stopAdvertising()
        self.delegate!.blePeripheralDidStop()
        self.delegate = nil
    }
    
    func openService() {
        // Start with the CBMutableCharacteristic
        self.wctCharacteristic = CBMutableCharacteristic(
            type: BLEIDs.wctCharacteristic,
            properties: CBCharacteristicProperties.Notify,
            value: nil, permissions: CBAttributePermissions.Readable)
        
        // Then the service
        self.wctService = CBMutableService(type: BLEIDs.wctService, primary: true)
        
        // Add the characteristic to the service
        self.wctService!.characteristics = [self.wctCharacteristic!]
        
        // finally, add the service to peripheral manager
        self.wctPeripheral!.addService(self.wctService)
        
        println(self.wctService?.peripheral?.name)
        
        println("BLE service is set up.")
        
    }
    
    
    func sendDataSequence() -> Bool {
        if self.wctSequence == .None {
            println("sent data: none")
            return false
        }
        
        var rawValue = self.wctSequence.rawValue
        if self.wctSequence == .Token {
            rawValue += ":\(self.data_token)"
        }
        else if self.wctSequence == .Error {
            rawValue += ":\(self.data_error)"
        }
        
        var didSend = self.wctPeripheral?.updateValue(BLEIDs.getSequenceData(rawValue), forCharacteristic: self.wctCharacteristic, onSubscribedCentrals: [self.wctConnectedCentral!])
        
        if didSend! {
            println("sent Data ok: \(rawValue)" )
            
            switch self.wctSequence {
            case .Init: self.wctSequence = .Working
            case .Working: self.wctSequence = .Ready
            case .Ready: self.wctSequence = .Token
            case .Token: self.wctSequence = .End
            case .Error: self.wctSequence = .End

            default:
                self.wctSequence = .None
                self.closePeripheral()
            }
            
            self.delegate!.blePeripheralDidSendData()
        }
        else {
            println("sent data failed: \(rawValue). will send again")
        }
        
        return didSend!
    }
    
    
    /** Required protocol method.  A full app should take care of all the possible states,
    *  but we're just waiting for  to know when the CBPeripheralManager is ready
    */
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        if let err = error {
            println("peripheralManagerDidStartAdvertising error: " + err.localizedFailureReason!)
            self.delegate!.blePeripheralMsgUpdate("Bluetooth BLE error of advertising...\(err.localizedFailureReason!)")
        }
        else {
            println("peripheralManagerDidStartAdvertising ok")
            self.delegate!.blePeripheralMsgUpdate("Bluetooth BLE is waiting to connect...")
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        // opt out from any other state
        var statusMsg = "BLuetooth error..."
        switch peripheral.state {
        case .Unknown: statusMsg = "BLE Bluetoothe state is unknown"
        case .Unsupported: statusMsg = "BLE Bluetooth is not supported on this device"
        case .Unauthorized: statusMsg = "Needs your approval to use BLE Bluetooth on this device"
        case .Resetting: statusMsg = "BLE Bluetooth is resetting, please wait..."
        case .PoweredOff: statusMsg = "Please turn on Bluetooth from settings and come back"
        default:
            statusMsg = "Bluetooth BLE is ready..."
        }
        self.delegate!.blePeripheralMsgUpdate(statusMsg)
        
        
        if (peripheral.state != CBPeripheralManagerState.PoweredOn) {
            println("needs state: CBPeripheralManagerState.PoweredOn, but got \(peripheral.state.rawValue). quit.")
        }
        else {
            // we're in CBPeripheralManagerState.PoweredOn state now
            println("BLE powered on")
        
            self.openService()
            self.delegate!.blePeripheralIsReady()
        }
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        println("Central subscribed to characteristic")
        
        self.wctConnectedCentral = central
        self.wctSequence = .Init
        self.sendDataSequence()
        self.delegate!.blePeripheralMsgUpdate("Data requester is connected...")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!) {
        self.wctConnectedCentral = nil
        println("Central unsubscribed from characteristic")
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        println("Underlining transmit queue is ready, ready to update central again")

        self.sendDataSequence()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveReadRequest request: CBATTRequest!) {
        println("Central read request")
        
//        self.sendDataSequence(self.wctSequence)
//        self.delegate!.blePeripheralMsgUpdate("Sending updating data...")
//        self.delegate!.blePeripheralIsUpdating()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, willRestoreState dict: [NSObject : AnyObject]!) {
        println("willRestoreState")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveWriteRequests requests: [AnyObject]!) {
        println("didReceiveWriteRequests")
    }
}
