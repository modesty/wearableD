//
//  LoaderView.swift
//  WearableD
//
//  Created by Ryan Ford on 2/16/15.
//  Copyright (c) 2015 Intuit. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class Loader : UIView {
    var loaderOne = LoadingPageView(frame: CGRect(x: 0, y: 0, width: 175, height: 250))
    var loaderTwo = LoadingPageView(frame: CGRect(x: 0, y: 0, width: 175, height: 250))
    private var keepAnimating = false;
    
    var transitionOptions = UIViewAnimationOptions.TransitionCurlUp
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupView () {
        self.addSubview(self.loaderTwo)
        self.addSubview(self.loaderOne)
    }
    
    
    
    func startAnimating (transitionOps : UIViewAnimationOptions?) {
        if transitionOps != nil {
            self.transitionOptions = transitionOps!
        }
        self.keepAnimating = true;
        self.loaderOne.startAnimation() {
            if self.keepAnimating {
               self.flip()
            }
            
        }
    }
    
    func stopAnimating () {
        self.keepAnimating = false
    }
        
    func hide (callback : () -> ()) {
        self.stopAnimating();
        let duration = 0.3
        let delay = 0.0 // delay will be 0.0 seconds (e.g. nothing)
        let options = UIViewAnimationOptions.CurveEaseInOut
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
            self.alpha = 0.0
            
            }, completion: { finished in
                self.stopAnimating()
                callback()
        })
    }
    
    func flip () {
        // create view tuple
        var views : (frontView: LoadingPageView, backView: LoadingPageView)
        
        if self.loaderOne.superview != nil {
            views = (frontView: self.loaderOne, backView: self.loaderTwo)
        }
        else {
            views = (frontView: self.loaderTwo,  backView: self.loaderOne)
        }
                
        UIView.transitionFromView(views.frontView, toView: views.backView, duration: 1.5, options: self.transitionOptions, completion: { void in
            views.backView.startAnimation() {
                if self.keepAnimating {
                    self.flip()
                }
            }
            
        })
    }
}