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

}

