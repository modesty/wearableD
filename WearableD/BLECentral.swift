//
//  BLECentral.swift
//  WearableD
//
//  Created by Ryan Ford on 1/14/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLECentralDelegate {
    func bleCentralStatusUpdate (update : String)
    func bleCentralIsReady()
    func bleCentralCharactoristicValueUpdate (update: String)
    func bleDidEncouneterError(error : NSError)
    func bleCentralDidStop()
}

class BLECentral : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var devices: CBPeripheral? = nil
    var myCentralManager : CBCentralManager? = nil
    var delegate : BLECentralDelegate? = nil
    let wctService = BLEIDs.wctService
    
    init (delegate : BLECentralDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func openBLECentral() {
        closeBLECentral()
        myCentralManager = CBCentralManager(delegate: self, queue : nil)
    }
    
    func closeBLECentral() {
        if self.myCentralManager != nil  {
            myCentralManager?.stopScan()
            
            if self.devices != nil {
                myCentralManager?.cancelPeripheralConnection(self.devices)
            }
            
            self.delegate?.bleCentralDidStop()
        }
        self.devices = nil
        self.myCentralManager = nil
    }
    
    
    //delegate method called after CBCentralManager constructor
    func centralManagerDidUpdateState(central: CBCentralManager!)  {
        
        var statusMsg = "Bluetooth LE error..."
        
        switch central.state {
        case .Unknown: statusMsg = "Bluetoothe LE state is unknown"
        case .Unsupported: statusMsg = "Bluetooth LE is not supported on this device"
        case .Unauthorized: statusMsg = "Needs your approval to use Bluetooth LE on this device"
        case .Resetting: statusMsg = "Bluetooth LE is resetting, please wait..."
        case .PoweredOff: statusMsg = "Please turn on Bluetooth from settings and come back"
        default:
            statusMsg = "Bluetooth LE is ready..."
        }
        
        //make sure the device has bluetooth turned on
        if central.state == .PoweredOn {
            //once it is on scan for peripherals - nil will find everything. typically should pass a UUID as frist arg
            myCentralManager?.scanForPeripheralsWithServices([wctService], options: nil)
            //myCentralManager?.scanForPeripheralsWithServices(nil, options: nil)
            statusMsg = "Searching for device ..."
            self.delegate?.bleCentralIsReady()
        }
        else {
            println("needs state: CBcentralState.PoweredOn, but got \(central.state.rawValue). quit.")
        }
    
        self.delegate?.bleCentralStatusUpdate(statusMsg)
    }
    
    //delegate called when a peripheral is found
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        var name = peripheral!.name == nil ? "" : peripheral!.name
        self.delegate?.bleCentralStatusUpdate("Found Peripheral:  \(name). Connecting...")
        devices = peripheral
        myCentralManager?.connectPeripheral(peripheral, options: nil)
    }
    
    //delegate called when a peripheral connects
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        self.delegate?.bleCentralStatusUpdate("Peripheral Connected. Scanning will stop and start to look for services...")

        //stop scaning after per conection
        myCentralManager?.stopScan();

        peripheral.delegate = self
        //pass service uuid here
        //peripheral.discoverServices(nil)
        peripheral.discoverServices([wctService])
    }
    
    //delegate called when a service is called
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if (error != nil) {
            self.delegate?.bleDidEncouneterError(error)
            println("there was an error contecting to the service")
        }
        else {
            for service in peripheral.services {
                self.delegate?.bleCentralStatusUpdate("Service Found: \(service.UUIDString). Start to look for characteristics...")
                peripheral.discoverCharacteristics(nil, forService : service as CBService)
                
            }
            
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if (error != nil) {
            self.delegate?.bleDidEncouneterError(error)
            println("there was an error discovering char")
        }
        else {
            for characteristic in service.characteristics {
                self.delegate?.bleCentralStatusUpdate("Characteristic Found: \(characteristic.UUIDString). Start to subscribe value updates...")
                //peripheral.readValueForCharacteristic(characteristic as CBCharacteristic)
                
                
                //subscibe to value updates
                peripheral.setNotifyValue(true, forCharacteristic : characteristic as CBCharacteristic)
            }
        }
        
    }
    
    
    //delgate called when attempting to read a value from a char
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if error != nil {
            self.delegate?.bleDidEncouneterError(error)
            println("there was an error reading char value")
        }
        else {
            self.delegate?.bleCentralStatusUpdate("Read characteristic Value")
            var rawValue = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)
            
            if let value = rawValue {
                println("data read from characteristic - \(value)")
                self.delegate?.bleCentralCharactoristicValueUpdate(value)
            }
            else {
                self.delegate?.bleCentralCharactoristicValueUpdate("No Value Found")
            }
        }
        
    }
    
    //delegate called when attempting to subsribe to a char
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        var rawValue : NSString?
        
        if error != nil {
            self.delegate?.bleDidEncouneterError(error)
            println("error subscribing to char")
        }
        else {
            self.delegate?.bleCentralStatusUpdate("Subscribing to characteristic Value")
            if characteristic.value != nil {
                rawValue = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)
                if let value = rawValue {
                    self.delegate?.bleCentralCharactoristicValueUpdate(value)
                    println("data updated from characteristic - \(value)")
                }
                else {
                    self.delegate?.bleCentralCharactoristicValueUpdate("No Value Found")
                }
            }
        }
        
    }
}