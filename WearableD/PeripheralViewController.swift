//
//  PeripheralViewController.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/9/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import UIKit
import CoreBluetooth


//Get these settings from your OAuth2 provider first
let OAuth2Settings = OAuth2Keys(
    baseURL: "https://",
    authorizeURL: "",
    tokenURL: "",
    redirectURL: "",
    clientID: "",
    clientSecret: "",
    scope: "",
    state: "wearableD",
    tokenCache: false
)

class PeripheralViewController: UIViewController, BLEPeripheralDelegate {
    
    var wctPeripheral: BLEPeripheral? = nil

    @IBOutlet weak var bleStatusMsg: UILabel!
    
    @IBOutlet weak var loadingContainer: UIView!
    
    var loader = Loader(frame: CGRect(x: 0, y: 0, width: 175, height: 250))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingContainer?.addSubview(self.loader)

        //uncomment this for emulator
        //self.startLoader()
        
        var client = OAuth2Client(controller: self, settings: OAuth2Settings);
        client.retrieveAccessToken({ (authToken) -> Void in
            if let optionnalAuthToken = authToken {
                println("Received access token " + optionnalAuthToken)
                
                self.blePeripheralMsgUpdate("Got access token...")
                self.wctPeripheral = BLEPeripheral()
                self.wctPeripheral?.raw_token = optionnalAuthToken
                self.wctPeripheral?.openPeripheral(self)
            }
            else {
                println("No access token completed...")
                self.stopLoader()
                self.blePeripheralMsgUpdate("No access token received, please try again.")
            }
        })
    }
    
    func startLoader () {
        self.loader.startAnimating(UIViewAnimationOptions.TransitionCurlUp)
    }
    func stopLoader () {
        self.loader.stopAnimating(nil)
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
        wctPeripheral?.closePeripheral()

        self.stopLoader()
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
//        println("\(_stdlib_getTypeName(self)) - blePeripheralIsReady")
        self.startLoader()
        wctPeripheral?.startPeripheral()
    }
    
    func blePeripheralDidSendData(dataSequence: BLESequence) {
//        println("\(_stdlib_getTypeName(self)) - blePeripheralIsworking")
        
        switch dataSequence {
        case .Init: self.wctPeripheral?.wctSequence = .Working
        case .Working: self.wctPeripheral?.wctSequence = .Ready
        case .Ready: self.wctPeripheral?.wctSequence = .Token
        case .Token:
            if self.wctPeripheral!.is_all_chunk_sent {
                self.wctPeripheral?.wctSequence = .End
            }
            else {
                self.wctPeripheral?.wctSequence = .Token
            }
        case .Error: self.wctPeripheral?.wctSequence = .End
        case .End:
            self.wctPeripheral?.wctSequence = .None
            self.wctPeripheral?.closePeripheral()
            
        default:
            self.wctPeripheral?.wctSequence = .None
        }
        
//TODO: remove this delay start next sequence, do real work
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
            self.sendDataSequenceToCentral()
        })
    }
    
    func blePeripheralDidStop() {
//        println("\(_stdlib_getTypeName(self)) - blePerpheralDidStop")
        self.loader.stopAnimating() {
           self.blePeripheralMsgUpdate("Token sent. Connection is closed.")
        }
        
    }
    
    func sendDataSequenceToCentral() {
        if (self.wctPeripheral?.wctSequence != .None) {
            self.wctPeripheral?.sendDataSequence()
        }
    }

}
