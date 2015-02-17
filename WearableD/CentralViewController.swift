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
    
    @IBOutlet weak var loadingContainer: UIView!
    @IBOutlet weak var showBtnFirst: UIButton!    
    @IBOutlet weak var showBtnSecond: UIButton!
    
    var loader = Loader(frame: CGRect(x: 0, y: 0, width: 175, height: 250))

    
    var access_token: String = ""
    var chunks_count: String = ""
    var retrieved_list: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadingContainer?.addSubview(self.loader)
        
        //uncomment this line when using emulator
        //self.startLoader()
        
        var delta: Int64 = 1 * Int64(NSEC_PER_SEC)
        
        var time = dispatch_time(DISPATCH_TIME_NOW, delta)
        
        dispatch_after(time, dispatch_get_main_queue(), {
            println("run")
            //self.loader.hide()
        })

        self.retrieved_list = []
        
        self.showHideNavButton(self.showBtnFirst, titleTxt: "")
        self.showHideNavButton(self.showBtnSecond, titleTxt: "")
        
        centralManager = BLECentral(delegate: self)
        centralManager?.openBLECentral()

//        self.access_token = ""
//        self.retrieveDocsListByToken()
    }
    

    func startLoader () {
        self.loader.startAnimating(UIViewAnimationOptions.TransitionCurlDown)
    }
    func stopLoader () {
        self.loader.stopAnimating()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Requesting"
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.title = "Back"
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        stopLoader()
        self.centralManager?.closeBLECentral()
        super.viewDidDisappear(animated)
    }
    
    func bleCentralStatusUpdate (update : String) {
        self.statusLabel.text = update
    }
    
    func bleCentralCharactoristicValueUpdate (update : String) {
        self.bleCentralStatusUpdate("Received data: \(update)")
        parsePeripheralData(update)
    }
    
    func bleDidEncouneterError (error : NSError) {
        println(error)
    }
    
    func bleCentralIsReady() {
        self.startLoader()
    }
    
    func bleCentralDidStop() {
        self.stopLoader()
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
            
            println("Got access_token \(self.access_token)")
            self.retrieveDocsListByToken()
        }
        else if update == BLESequence.Init.rawValue {
            self.access_token = ""
        }
        else {
            let values = update.componentsSeparatedByString(":")
            if values.count == 2 {
                if values[0] == BLESequence.Ready.rawValue {
                    self.chunks_count = values[1]
                    println("")
                }
                else if values[0] == BLESequence.Token.rawValue {
                    self.access_token += values[1]
                }
                else if values[0] == BLESequence.Error.rawValue {
                    println("data error: \(values[1])")
                }
            }
        }
    }
    
    
    func retrieveDocsListByToken() {
        if self.access_token.isEmpty {
            return
        }
        self.startLoader()
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
                self.stopLoader()
                
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
        if let dataList = jsonData.objectForKey("data") as NSArray? {
            retrieved_list = dataList
            let numOfReturns = retrieved_list.count
            if numOfReturns < 1 {
                self.bleCentralStatusUpdate("No tax return found.")
            }
            else {
                let doc = retrieved_list[0] as? NSDictionary
                let name = doc!["name"] as String
                self.bleCentralStatusUpdate("Got \(numOfReturns) Tax Returns for \(name)")
                
                self.loader.hide() {
                    if self.retrieved_list.count > 0 {
                        self.showNavBtnWithData(self.showBtnFirst, doc: self.retrieved_list[0] as? NSDictionary)
                    }
                    if self.retrieved_list.count > 1 {
                        self.showNavBtnWithData(self.showBtnSecond, doc: self.retrieved_list[1] as? NSDictionary)
                    }
                }
            
             
            }
        }
        else {
            var errMsg = "No tax return found."
            if let statusObj = jsonData.objectForKey("status") as NSDictionary? {
                let message = statusObj["message"] as String
                let code = statusObj["code"] as Int
                errMsg = "\(message). Error code: \(code)."
            }
            self.bleCentralStatusUpdate(errMsg)
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
