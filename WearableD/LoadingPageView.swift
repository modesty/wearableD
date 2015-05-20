//
//  LoadingView.swift
//  WearableD
//
//  Created by Ryan Ford on 2/16/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class LoadingPageView : UIView {
    
    var loadingLines = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
    }

    func setupView () -> Void {
        self.backgroundColor = UIColor(red: CGFloat(97/255.0), green: CGFloat(209/255.0), blue: CGFloat(242/255.0), alpha: 1.0)
        self.createLoadingLines(5, lineSpacing: 30)
    }
    
    func resetLineState () {
        for index in 0...4 {
            var lineView = self.loadingLines[index];
            lineView.bounds.size.width = CGFloat(0);
        }
    }
    
    func createLoadingLines ( lineCount : Int, lineSpacing : Int)  -> Void {
        for index in 1...lineCount {
            var lineView = UIView()
            let height = 10;
            var space = (index * lineSpacing) + height;
            //todo make width relative to passed in frame
            lineView.frame = CGRect(x: 15, y: space, width: 0, height: height);
            lineView.backgroundColor = UIColor.whiteColor();
            
            self.loadingLines.append(lineView)
            self.addSubview(lineView)
            
        }
        
    }
    
    func startAnimation (callback : () -> ()) {
        self.animateLines(0, callback: callback)
    }
    func animateLines (index: Int, callback: () -> ()) {
        let duration = 0.5
        let delay = 0.0 // delay will be 0.0 seconds (e.g. nothing)
        let options = UIViewAnimationOptions.CurveEaseInOut
        var lineView = self.loadingLines[index];
        //reset width.
        lineView.bounds.size.width = CGFloat(0);
        lineView.center.x = 0.0
        
        var frame = lineView.frame
        frame.size.width = 145;
        frame.origin.x = 15.0
        
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
            lineView.frame = frame
            
            }, completion: { finished in
                if (index == self.loadingLines.count - 1 ) {
                    self.resetLineState()
                    callback()
                }
                else {
                    var i = index
                    i++
                    self.animateLines(i, callback: callback)
                }
        })
    }
}
