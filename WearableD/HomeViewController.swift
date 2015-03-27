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
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleWatchKitNotification:", name: "WearableDWKMsg", object: nil)
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
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let topVC = self.navigationController?.topViewController
                var bleVC: UIViewController? = nil
                
                if viewNameStr == "requestDoc" {
                    if (topVC is CentralViewController) == false {
                        self.returnToRoot()
                        bleVC = mainStoryboard.instantiateViewControllerWithIdentifier("CentralViewController") as CentralViewController
                    }
                }
                else if viewNameStr == "shareDoc" {
                    if (topVC is PeripheralViewController) == false {
                        self.returnToRoot()
                        bleVC = mainStoryboard.instantiateViewControllerWithIdentifier("PeripheralViewController") as PeripheralViewController
                    }
                }
                
                if bleVC != nil {
                    self.navigationController?.pushViewController(bleVC!, animated: true)
                }
            }
        }
    }
    
    func returnToRoot() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}

