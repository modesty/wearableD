//
//  InterfaceController.swift
//  WearableD WatchKit Extension
//
//  Created by Zhang, Modesty on 3/24/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBAction func onRequestDoc() {
        openParentAppWithView("requestDoc")
    }
    
    @IBAction func onShareDoc() {
        openParentAppWithView("shareDoc")
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func openParentAppWithView(viewName: String) {
        WKInterfaceController.openParentApplication(["viewName": viewName],
            reply: { (replyInfo, error) -> Void in
                NSLog("Get reply from parent app: \(replyInfo)")
        })
    }

}
