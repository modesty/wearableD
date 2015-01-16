//
//  CentralViewController.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/9/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import UIKit
import QuartzCore

class CentralViewController: UIViewController, BLECentralProtocal {
    var centralManager : BLECentral?

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = BLECentral(delegate: self)
        centralManager?.scanForPeripherals()
        

        // Do any additional setup after loading the view.
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
        println("Update from Central Char Value")
        println(update)
        self.valueLabel.text = update
    }
    
    func bleDidEncouneterError (error : NSError) {
        println(error)
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

}
