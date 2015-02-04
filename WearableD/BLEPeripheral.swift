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
    private var data_token: [String]
    // token chunk idx
    private var chunk_idx = 0
    
    private var _raw_token: String
    var raw_token: String {
        get {
            return _raw_token
        }
        
        set (rawValue) {
            _raw_token = rawValue
            println("AUTH TOEKEN LENGTH: \(countElements(_raw_token))")
            
            var str = rawValue
            //MQZ.2/3/2015 max-chunk-length is 150
            var chunkLength = 120
            var chunks = [String]()
            var startIndex = str.startIndex
            
            var chunkAmount = Int(countElements(_raw_token) / chunkLength) + 1
            while chunkAmount > 0 {
                var oneLength = chunkLength
                if chunkAmount == 1 {
                    oneLength = countElements(str) - Int(countElements(_raw_token) / chunkLength) * chunkLength
                }
                var endIndex = advance(startIndex, oneLength)
                
                var chunk = str.substringWithRange(Range(start: startIndex, end: endIndex))
                chunks.append(chunk)
                
                startIndex = endIndex
                chunkAmount--
            }
            
            data_token = chunks
        }
    }
    
    var is_all_chunk_sent: Bool {
        get {
            return (self.chunk_idx == self.data_token.count) ? true : false
        }
    }
    
    override init() {
        self.wctPeripheral = nil
        self.wctService = nil
        self.wctCharacteristic = nil
        
        self.wctSequence = .None
        self.wctConnectedCentral = nil
        
        self.data_error = ""
        self.data_token = [String]()
        self.delegate = nil
        
        self._raw_token = ""
        
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
        
        if self.wctSequence == .Init {
            self.chunk_idx = 0
        }
        else if self.wctSequence == .Ready {
            rawValue += ":\(self.data_token.count)"
            println("ready for token: \(self.data_token.count) chunks")
        }
        else if self.wctSequence == .Token {
            rawValue += ":\(self.data_token[self.chunk_idx])"
            println("sending token: \(self.data_token[self.chunk_idx]) - \(self.chunk_idx) of \(self.data_token.count)")
        }
        else if self.wctSequence == .Error {
            rawValue += ":\(self.data_error)"
            println("sending error:\(self.data_error)")
        }
        
        var didSend = self.wctPeripheral?.updateValue(BLEIDs.getSequenceData(rawValue), forCharacteristic: self.wctCharacteristic, onSubscribedCentrals: [self.wctConnectedCentral!])
        
        if didSend! {
            println("sent Data ok: \(rawValue)")
            if self.wctSequence == .Token {
                self.chunk_idx++
            }
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
