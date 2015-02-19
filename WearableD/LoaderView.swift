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
    private var loaderOne = LoadingPageView(frame: CGRect(x: 0, y: 0, width: 175, height: 250))
    private var loaderTwo = LoadingPageView(frame: CGRect(x: 0, y: 0, width: 175, height: 250))

    private var keepAnimating = false;
    private var transitionOptions = UIViewAnimationOptions.TransitionCurlUp

    private var animatingView: LoadingPageView? = nil
    private var callback: (()->())? = nil
    
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
        
        if !self.keepAnimating {
            self.keepAnimating = true;
            self.animatingView = self.loaderOne
            self.animateLoop()
        }
    }
    
    private func animateLoop() {
        if self.animatingView != nil && self.keepAnimating {
            self.animatingView?.startAnimation() {
                if self.keepAnimating {
                    self.flip()
                }
                else {
                    self.hide()
                }
            }
        }
        else {
            self.hide()
        }
    }
    
    func stopAnimating( callback : (() -> ())? ) {
        println("stop animating...")
        self.keepAnimating = false
        
        if callback != nil {
            self.callback = callback
        }
    }
        
    private func hide () {
        let duration = 1.0
        let delay = 1.0 // delay will be 0.0 seconds (e.g. nothing)
        let options = UIViewAnimationOptions.CurveEaseInOut
        UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
            self.alpha = 0.0
            }, completion: { finished in
                println("faded out: \(finished)")
                self.callback?()
                self.callback = nil
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
                
        println("starting transition")
        UIView.transitionFromView(views.frontView, toView: views.backView, duration: 1.5, options: self.transitionOptions, completion: { finished in
            println("stopping transition: \(finished)")
            self.animatingView = views.backView
            self.animateLoop()
        })
    }
}