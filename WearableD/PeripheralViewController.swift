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
    
    var wctPeripheral: BLEPeripheral! = nil
    
    @IBOutlet weak var bleStatusMsg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        wctPeripheral = BLEPeripheral()
        wctPeripheral.openPeripheral(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        wctPeripheral.closePeripheral()
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
        wctPeripheral.startPeripheral()
    }
    
    func blePeripheralDidSendData() {
        println("\(_stdlib_getTypeName(self)) - blePeripheralIsworking")
        
        self.wctPeripheral.sendDataSequence()
    }
    
    func blePeripheralDidStop() {
        println("\(_stdlib_getTypeName(self)) - blePerpheralDidStop")
    }

}
