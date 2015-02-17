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
    var loaderOne = LoadingView(frame: CGRect(x: 0, y: 0, width: 175, height: 250))
    var loaderTwo = LoadingView(frame: CGRect(x: 0, y: 0, width: 175, height: 250))
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
    
    func startAnimation (transitionOps : UIViewAnimationOptions?) {
        if transitionOps != nil {
            println("seeting opts")
            self.transitionOptions = transitionOps!
        }        
        self.loaderOne.startAnimation() {
            self.flip()
        }
    }
    
    func flip () {
        // create view tuple
        var views : (frontView: LoadingView, backView: LoadingView)
        
        if self.loaderOne.superview != nil {
            views = (frontView: self.loaderOne, backView: self.loaderTwo)
        }
        else {
            views = (frontView: self.loaderTwo,  backView: self.loaderOne)
        }
        
        // set a transition style
        //let transitionOptions = UIViewAnimationOptions.TransitionCurlUp
        
        UIView.transitionFromView(views.frontView, toView: views.backView, duration: 1.5, options: self.transitionOptions, completion: { void in
            views.backView.startAnimation() {
                self.flip()
            }
            
        })
    }
}