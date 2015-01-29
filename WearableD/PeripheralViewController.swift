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
        self.bleSpinner.stopAnimating()
        //wctPeripheral = BLEPeripheral()
        //wctPeripheral!.openPeripheral(self)
        var client = OAuth2Client(controller: self);
        client.retrieveAuthToken({ (authToken) -> Void in
            if let optionnalAuthToken = authToken {
                println("Received access token " + optionnalAuthToken)
            }
        
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Sharing"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        wctPeripheral!.closePeripheral()
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
        case .Ready: self.wctPeripheral?.wctSequence = .Token
        case .Token: self.wctPeripheral?.wctSequence = .End
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
