//
//  PDFViewController.swift
//  WearableD
//
//  Created by Zhang, Modesty on 1/24/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var access_token: String = ""
    var document_id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if access_token.isEmpty || document_id.isEmpty {
            showHTTPPDF()
        }
        else {
            println("document_id: \(document_id)")
            println("access_token: \(access_token)")
            showTaxDocument()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Retrieved PDF"
        super.viewWillAppear(animated)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showHTTPPDF() {
        let pdfUrl = NSURL(string: "http://unleash.intuitlabs.com/ionweb/assets/Intuit_API_OAuth2_Spec.pdf")
        var request = NSMutableURLRequest(URL: pdfUrl!)
        request.addValue("Bearer iOS PDFViewController TEST", forHTTPHeaderField: "Authorization")
        self.webView.loadRequest(request)
    }
    
    func showTaxDocument() {
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: "\(BLEIDs.ctHost)/unleash/v1/taxdocs/\(self.document_id)")
        request.HTTPMethod = "GET"
        request.addValue("application/pdf", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(self.access_token)", forHTTPHeaderField: "Authorization")
        request.addValue("docs", forHTTPHeaderField: "x-request-type")
        request.addValue(BLEIDs.getCTTransId(), forHTTPHeaderField: "intuit_tid")

        self.webView.loadRequest(request)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let headerFields = request.allHTTPHeaderFields
        println()
        println("PDFViewController Request - start")
        for headerField in headerFields?.keys.array as [String] {
            let headerValue = request.valueForHTTPHeaderField(headerField)
            println("\(headerField) : \(headerValue!)")
        }
        println("PDFViewController Request - end")
     
        return true
    }

}
