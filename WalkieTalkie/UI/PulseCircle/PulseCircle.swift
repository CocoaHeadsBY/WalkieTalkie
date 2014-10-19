//
//  PulseCircle.swift
//  WalkieTalkie
//
//  Created by Konstantin Salak on 18/10/14.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

import UIKit

class PulseCircle: UIView {
    var kAnimationDuration = 1.5
    var kReverseAnimation = false
    var kReverseAlphaAnimation = false
    
    var transmitterState: TransmitterState {
        didSet{
            self.updateAppearanceForState(self.transmitterState)
        }
    }

    @IBInspectable var circleColor : UIColor?{
        didSet{
            self.updateProperties()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        transmitterState = .NotAvailable
        super.init(coder: aDecoder)
    }
    
    override class func layerClass() -> AnyClass{
        return CAShapeLayer.classForCoder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setLayerProperties()
        self.attachAnimations()
    }
    
    func setLayerProperties() {
        var layer = self.layer as CAShapeLayer
        
        var minLength : CGFloat = 50.0//min(self.frame.height, self.frame.width)

        layer.path = UIBezierPath(ovalInRect: self.bounds).CGPath
        layer.fillColor = self.circleColor?.CGColor
    }
    
    func updateConstantsForState(state : TransmitterState){
        switch state{
        case .Receiving:
            kAnimationDuration = 0.3
        case .Sending:
            kAnimationDuration = 0.5
        case .NotAvailable:
            kAnimationDuration = 2.0
        case .Idle:
            kAnimationDuration = 1.5
        }
        
        
        switch state{
        case .Receiving:
            kReverseAnimation = true
            kReverseAlphaAnimation = false
        case .Sending:
            kReverseAnimation = false
            kReverseAlphaAnimation = false
        case .Idle:
            kReverseAnimation = false
            kReverseAlphaAnimation = false
        case .NotAvailable:
            kReverseAnimation = false
            kReverseAlphaAnimation = false
        }
    }
    
    func updateAppearanceForState(state : TransmitterState){
        self.updateConstantsForState(state)
        
        self.attachAnimations()
        self.updateProperties()
    }
    
    func attachAnimations() {
        self.attachAlphaAnimations()
        self.attachSizeAnimations()
    }
    
    func updateProperties(){
        println("update properties of PulseCircle")
//        self.layer.removeAllAnimations()
        
        
        self.attachAnimations()
        self.setLayerProperties()
    }
    
    func attachAlphaAnimations() {
        var animation = self.animationWithKeyPath("opacity")

        animation.fromValue = 0.8
        animation.toValue = 0.0
        animation.autoreverses = kReverseAlphaAnimation

        if kReverseAlphaAnimation {
            animation.duration = animation.duration / 2
        }
        
        self.layer.addAnimation(animation, forKey: animation.keyPath)
    }
    
    func attachSizeAnimations() {
        var animation = self.animationWithKeyPath("transform")
        
        var scaleFactor : CGFloat = 1.5
        var transform : CATransform3D = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)
        animation.toValue = NSValue(CATransform3D: transform)
        animation.autoreverses = kReverseAnimation
        
        self.layer.addAnimation(animation, forKey: animation.keyPath)
    }
    
    func animationWithKeyPath(keypath : String) -> CABasicAnimation {
        var anim = CABasicAnimation(keyPath: keypath)
        anim.repeatCount = HUGE
        anim.duration = kAnimationDuration
        
        return anim
    }
}
