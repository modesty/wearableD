//
//  CentralViewController.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/9/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import UIKit
import QuartzCore

class CentralViewController: UIViewController, BLECentralDelegate {
    var centralManager : BLECentral?

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var bleSpinner: UIActivityIndicatorView!
    
    var access_token: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.bleSpinner.stopAnimating()
        centralManager = BLECentral(delegate: self)
        centralManager?.openBLECentral()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Requesting"
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.bleSpinner.stopAnimating()
        self.centralManager?.closeBLECentral()
        super.viewDidDisappear(animated)
    }
    
    func bleCentralStatusUpdate (update : String) {
        self.statusLabel.text = update
        
//        UIView.animateWithDuration(2, animations: {
//            self.statusLabel.alpha = 0.0
//          
//            }, completion: {
//                (finished: Bool) -> Void in
//                //self.statusLabel.alpha = 1.0
//                self.statusLabel.text = update
//            
//            })
//        
//        println(update)
    }
    
    func bleCentralCharactoristicValueUpdate (update : String) {
        self.bleCentralStatusUpdate("Received data: \(update)")
        parsePeripheralData(update)
    }
    
    func bleDidEncouneterError (error : NSError) {
        println(error)
    }
    
    func bleCentralIsReady() {
        self.bleSpinner.startAnimating()
    }
    
    func bleCentralDidStop() {
        self.bleSpinner.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func parsePeripheralData(update: String) {
        
        if update == BLESequence.End.rawValue {
            self.centralManager?.closeBLECentral()
            self.bleCentralStatusUpdate("Received token. Retrieving data by token...")
        }
        else {
            let values = update.componentsSeparatedByString(":")
            if values.count == 2 {
                if values[0] == BLESequence.Token.rawValue {
                    self.access_token = values[1]
                    println("Got access_token: \(self.access_token)")
                }
            }
        }
    }
    
    func retrieveDataByToken() {
        if self.access_token.isEmpty {
            return
        }
        

    }

}
