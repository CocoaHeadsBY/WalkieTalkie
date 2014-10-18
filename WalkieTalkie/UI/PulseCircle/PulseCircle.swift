//
//  PulseCircle.swift
//  WalkieTalkie
//
//  Created by Konstantin Salak on 18/10/14.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

import UIKit

class PulseCircle: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    let kAnimationDuration = 1.5
    @IBInspectable var circleColor : UIColor?
    
    override class func layerClass() -> AnyClass{
        
        return CAShapeLayer.classForCoder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setLayerProperties()
        self.attachAnimations()
        
    }
    
    func setLayerProperties(){
        
        var layer = self.layer as CAShapeLayer
        
        var minLength : CGFloat = 50.0//min(self.frame.height, self.frame.width)

        layer.path = UIBezierPath(ovalInRect: self.bounds).CGPath
//        layer.path = UIBezierPath(ovalInRect: CGRectMake(50, 50, minLength, minLength)).CGPath
        layer.fillColor = self.circleColor?.CGColor
    }
    
    func attachAnimations(){
        self.attachAlphaAnimations()
        self.attachSizeAnimations()
    }
    
    func attachAlphaAnimations(){
        
        var animation = self.animationWithKeyPath("opacity")

        animation.fromValue = 0.8
        animation.toValue = 0.0
        
        self.layer.addAnimation(animation, forKey: animation.keyPath)
    }
    
    func attachSizeAnimations(){
        println("attach size animations")
        var animation = self.animationWithKeyPath("transform")
        
        var scaleFactor : CGFloat = 1.5
        var transform : CATransform3D = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)
        animation.toValue = NSValue(CATransform3D: transform)
        
        self.layer.addAnimation(animation, forKey: animation.keyPath)
    }
    
    func animationWithKeyPath(keypath : String) -> CABasicAnimation {
        var anim = CABasicAnimation(keyPath: keypath)
        anim.repeatCount = HUGE
        anim.duration = kAnimationDuration
        
        return anim
    }
    
}
