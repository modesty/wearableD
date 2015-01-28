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
    
    @IBOutlet weak var showBtnFirst: UIButton!    
    @IBOutlet weak var showBtnSecond: UIButton!
    
    var access_token: String = ""
    var retrieved_list: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.bleSpinner.stopAnimating()
        self.retrieved_list = []
        
        self.showHideNavButton(self.showBtnFirst, titleTxt: "")
        self.showHideNavButton(self.showBtnSecond, titleTxt: "")
        
        centralManager = BLECentral(delegate: self)
        centralManager?.openBLECentral()

//        self.access_token = ""
//        self.retrieveDocsListByToken()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Requesting"
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.title = "Back"
        super.viewWillDisappear(animated)
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
    
    
    func retrieveDocsListByToken() {
        if self.access_token.isEmpty {
            return
        }

        self.bleSpinner.startAnimating()
        self.bleCentralStatusUpdate("Retrieveing Tax Return list...")
        
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: "\(BLEIDs.ctHost)/unleash/v1/taxdocs")
        request.HTTPMethod = "GET"
        request.addValue("Bearer \(self.access_token)", forHTTPHeaderField: "Authorization")
        request.addValue("docs", forHTTPHeaderField: "x-request-type")
        request.addValue(BLEIDs.getCTTransId(), forHTTPHeaderField: "intuit_tid")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(),
            completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if error != nil {
                    println(error.localizedDescription)
                    self.bleCentralStatusUpdate("Error: \(error.localizedDescription) (Code:\(error.code))")
                }
                else {
                    var json_error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
                    let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: json_error) as? NSDictionary
            
                    if (jsonResult != nil) {
                        self.onDocsListReady(jsonResult)
                    } else {
                        let serializationError = json_error.memory as NSError?
                        self.bleCentralStatusUpdate("Error: \(serializationError!.localizedFailureReason) (Code:\(serializationError!.code))")
                    }
                }
                self.bleSpinner.stopAnimating()
        })
    }
    
    func showHideNavButton(btn: UIButton!, titleTxt: String!) {
        btn.setTitle(titleTxt, forState: nil)
        btn.hidden = titleTxt.isEmpty
        btn.enabled = !titleTxt.isEmpty
    }
    
    func showNavBtnWithData(btn: UIButton!, doc: NSDictionary?) {
        if doc == nil {
            self.showHideNavButton(btn, titleTxt: "")
        }
        else {
            var name = doc!["name"] as String
            var year = doc!["taxYear"] as String
            self.showHideNavButton(btn, titleTxt: "Show \(name) \(year) Return")
        }
    }
    
    
    func onDocsListReady(jsonData: NSDictionary!) {
        self.bleCentralStatusUpdate("Processing Tax Return list data...")
        retrieved_list = jsonData["data"] as NSArray
        let numOfReturns = retrieved_list.count
        if numOfReturns < 1 {
            self.bleCentralStatusUpdate("No tax return found.")
        }
        else {
            let doc = retrieved_list[0] as? NSDictionary
            let name = doc!["name"] as String
            self.bleCentralStatusUpdate("Got \(numOfReturns) Tax Returns for \(name)")
            
            self.showNavBtnWithData(self.showBtnFirst, doc: retrieved_list[0] as? NSDictionary)
            self.showNavBtnWithData(self.showBtnSecond, doc: retrieved_list[1] as? NSDictionary)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var showBtn = sender as UIButton
        var pdfVC = segue.destinationViewController as PDFViewController
        
        var docData = self.retrieved_list[showBtn.tag] as NSDictionary
        
        pdfVC.access_token = self.access_token
        pdfVC.document_id = docData["key"] as String
    }

}
