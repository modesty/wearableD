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
    func blePeripheralDidSendData(dataSequence: BLESequence)
    func blePeripheralDidStop()
}


class BLEPeripheral: NSObject, CBPeripheralManagerDelegate {
    var wctPeripheral: CBPeripheralManager?
    var wctService: CBMutableService?
    var wctCharacteristic: CBMutableCharacteristic?
    
    var wctSequence: BLESequence
    var wctConnectedCentral: CBCentral?
    
    var delegate: BLEPeripheralDelegate?
    
    // oAuth error or cancel
    var data_error: String
    // oAuth access token
    var data_token: [String]
    
    override init() {
        self.wctPeripheral = nil
        self.wctService = nil
        self.wctCharacteristic = nil
        
        self.wctSequence = .None
        self.wctConnectedCentral = nil
        
        self.data_error = ""
        self.data_token = [String]()
        self.delegate = nil
        
        super.init()
    }
    
    
    func openPeripheral(delegate: BLEPeripheralDelegate!) {
        self.delegate = delegate
        self.wctPeripheral = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func startPeripheral() {
        // start advertising with specific service uuid
        self.wctPeripheral?.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [BLEIDs.wctService] ])
    }
    
    func closePeripheral() {
        self.wctConnectedCentral = nil
        self.wctPeripheral?.stopAdvertising()
        self.delegate?.blePeripheralDidStop()
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
        self.wctService?.characteristics = [self.wctCharacteristic!]
        
        // finally, add the service to peripheral manager
        self.wctPeripheral!.addService(self.wctService)
        
        println(self.wctService?.peripheral?.name)
        
        println("BLE service is set up.")
        
    }
    

    func sendDataSequence() -> Bool {
        if self.wctSequence == .None {
            println("no data to sent, return")
            return false
        }
        
        if self.wctConnectedCentral == nil {
            println("connection already closed, return")
            return false
        }
        
        var rawValue = self.wctSequence.rawValue
        //use int values for token enum so no need to keep token count here
        if self.wctSequence == .Token1 {
            rawValue += ":\(self.data_token[0])"
            println("sending token:\(self.data_token[0])")
        }
        else if self.wctSequence == .Token2 {
            rawValue += ":\(self.data_token[1])"
            println("sending token:\(self.data_token[1])")
        }
        else if self.wctSequence == .Token3 {
            rawValue += ":\(self.data_token[2])"
            println("sending token:\(self.data_token[2])")
        }
        else if self.wctSequence == .Token4 {
            rawValue += ":\(self.data_token[3])"
            println("sending token:\(self.data_token[3])")
        }
        else if self.wctSequence == .Token5 {
            rawValue += ":\(self.data_token[4])"
            println("sending token:\(self.data_token[4])")
        }
        else if self.wctSequence == .Token6 {
            rawValue += ":\(self.data_token[5])"
            println("sending token:\(self.data_token[5])")
        }
        
        else if self.wctSequence == .Error {
            rawValue += ":\(self.data_error)"
            println("sending error:\(self.data_error)")
        }
        
        var didSend = self.wctPeripheral?.updateValue(BLEIDs.getSequenceData(rawValue), forCharacteristic: self.wctCharacteristic, onSubscribedCentrals: [self.wctConnectedCentral!])
        
        if didSend! {
            println("sent Data ok: \(rawValue)" )
            self.delegate!.blePeripheralDidSendData(self.wctSequence)
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
            self.delegate?.blePeripheralMsgUpdate("Bluetooth LE error of advertising...\(err.localizedFailureReason!)")
        }
        else {
            println("peripheralManagerDidStartAdvertising ok")
            self.delegate?.blePeripheralMsgUpdate("Bluetooth LE is waiting to connect...")
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        // opt out from any other state
        var statusMsg = "Bluetooth LE error..."
        switch peripheral.state {
        case .Unknown: statusMsg = "Bluetoothe LE state is unknown"
        case .Unsupported: statusMsg = "Bluetooth LE is not supported on this device"
        case .Unauthorized: statusMsg = "Needs your approval to use Bluetooth LE on this device"
        case .Resetting: statusMsg = "Bluetooth LE is resetting, please wait..."
        case .PoweredOff: statusMsg = "Please turn on Bluetooth from settings and come back"
        default:
            statusMsg = "Bluetooth LE is ready..."
        }
        self.delegate?.blePeripheralMsgUpdate(statusMsg)
        
        
        if (peripheral.state != CBPeripheralManagerState.PoweredOn) {
            println("needs state: CBPeripheralManagerState.PoweredOn, but got \(peripheral.state.rawValue). quit.")
        }
        else {
            // we're in CBPeripheralManagerState.PoweredOn state now
            println("BLE powered on")
        
            self.openService()
            self.delegate?.blePeripheralIsReady()
        }
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        println("Central subscribed to characteristic")
        
        self.wctConnectedCentral = central
        self.wctSequence = .Init
        self.sendDataSequence()
        self.delegate?.blePeripheralMsgUpdate("Data requester is connected...")
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
        
        self.sendDataSequence()
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, willRestoreState dict: [NSObject : AnyObject]!) {
        println("willRestoreState")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveWriteRequests requests: [AnyObject]!) {
        println("didReceiveWriteRequests")
    }
}
