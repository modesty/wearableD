//
//  PeripheralViewController.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/9/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController, BLEPeripheralDelegate {
    
    var wctPeripheral: BLEPeripheral? = nil

    
    @IBOutlet weak var bleSpinner: UIActivityIndicatorView!
    @IBOutlet weak var bleStatusMsg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.bleSpinner.startAnimating()
        
        var client = OAuth2Client(controller: self);
        client.retrieveAccessToken({ (authToken) -> Void in
            if let optionnalAuthToken = authToken {
                println("Received access token " + optionnalAuthToken)
                println("AUTH TOEKEN LENGTH")
                println(countElements(optionnalAuthToken))

                var str = optionnalAuthToken;
                var chunkAmount = 6
                var chunkLength = 110
                var chunks = [String]()
                var startIndex = str.startIndex
                var endIndex = advance(startIndex, chunkLength)
                
                while chunkAmount  > 0 {
                    var length = countElements(str)
                    if length < chunkLength {
                        endIndex = advance(startIndex, length)
                    }
                    var chunk = str.substringToIndex(endIndex)
                    chunks.append(chunk)
                    str.removeRange(Range(start : startIndex, end : endIndex))
                    chunkAmount--
                }
                
                println(chunks)
                
                
                self.blePeripheralMsgUpdate("Got access token...")
                self.wctPeripheral = BLEPeripheral()
                self.wctPeripheral!.data_token = chunks
                self.wctPeripheral!.openPeripheral(self)
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Sharing"
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        if wctPeripheral != nil {
            wctPeripheral!.closePeripheral()
        }
        
        self.bleSpinner.stopAnimating()
        super.viewWillDisappear(animated)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
//  BLEPeripheralDelegate required methods
    func blePeripheralMsgUpdate(textMsg:String!) {
        self.bleStatusMsg!.text = textMsg
    }

    func blePeripheralIsReady() {
        println("\(_stdlib_getTypeName(self)) - blePeripheralIsReady")
        self.bleSpinner.startAnimating()
        wctPeripheral?.startPeripheral()
    }
    
    func blePeripheralDidSendData(dataSequence: BLESequence) {
        println("\(_stdlib_getTypeName(self)) - blePeripheralIsworking")
        
        switch dataSequence {
        case .Init: self.wctPeripheral?.wctSequence = .Working
        case .Working: self.wctPeripheral?.wctSequence = .Ready
        case .Ready: self.wctPeripheral?.wctSequence = .Token1
        case .Token1: self.wctPeripheral?.wctSequence = .Token2
        case .Token2: self.wctPeripheral?.wctSequence = .Token3
        case .Token3: self.wctPeripheral?.wctSequence = .Token4
        case .Token4: self.wctPeripheral?.wctSequence = .Token5
        case .Token5: self.wctPeripheral?.wctSequence = .Token6
        case .Token6: self.wctPeripheral?.wctSequence = .End
        case .Error: self.wctPeripheral?.wctSequence = .End
        case .End:
            self.wctPeripheral?.wctSequence = .None
            self.wctPeripheral?.closePeripheral()
            
        default:
            self.wctPeripheral?.wctSequence = .None
        }
        
//TODO: remove this waiting 1s to start next sequence, do real work
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.sendDataSequenceToCentral()
        })
    }
    
    func blePeripheralDidStop() {
        println("\(_stdlib_getTypeName(self)) - blePerpheralDidStop")
        self.bleSpinner.stopAnimating()
        self.blePeripheralMsgUpdate("All data sent. Connection is closed.")
    }
    
    func sendDataSequenceToCentral() {
        if (self.wctPeripheral?.wctSequence != .None) {
            self.wctPeripheral?.sendDataSequence()
        }
    }

}
