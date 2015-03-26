//
//  ViewController.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/9/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleWatchKitNotification"), name: "WearableDWKMsg", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.title = "Wearable Transcript"
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.title = "Home"
        super.viewWillDisappear(animated)
    }
    
    func handleWatchKitNotification(notification: NSNotification) {
        println("Got notification: \(notification.object)")
        if let userInfo = notification.object as? [String:String] {
            if let viewNameStr = userInfo["viewName"] {
                if viewNameStr == "requestDoc" {
                    
                }
                else if viewNameStr == "shareDoc" {
                    
                }
            }
        }
    }

}

