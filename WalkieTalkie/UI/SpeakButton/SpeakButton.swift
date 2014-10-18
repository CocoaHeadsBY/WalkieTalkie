//
//  SpeakButton.swift
//  WalkieTalkie
//
//  Created by Konstantin Salak on 18/10/14.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

import Foundation
import UIKit

@objc protocol SpeakButtonDelegate {
    func speakButtonWasTouched(speakButton: SpeakButton)
    func speakButtonWasReleased(speakButton: SpeakButton)
}

class SpeakButton : UIView {
    @IBOutlet weak var overlayButton : UIButton!
    @IBOutlet weak var delegate: SpeakButtonDelegate?
    @IBOutlet weak var titleLabel : UILabel!

    var enabled : Bool {
        get{
            return overlayButton.enabled
        }
        set{
            overlayButton.enabled = newValue
            self.updateTitleLabel()
            self.backgroundColor = UIColor.lightGrayColor()
        }
    }
    
    func linkEvents() {

        self.overlayButton.addTarget(self, action: "didTouchDown:", forControlEvents: .TouchDown)
        self.overlayButton.addTarget(self, action: "didTouchUp:", forControlEvents: .TouchUpInside)
        self.overlayButton.addTarget(self, action: "didTouchUp:", forControlEvents: .TouchUpOutside)
    }
    
    func commonInit() {
        self.linkEvents()
        
        self.layer.cornerRadius = 10.0;
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.width / 2.0
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.addViewFromNib()
        self.commonInit()
    }
    
    func updateTitleLabel() {
        var newText : NSString

        switch (self.overlayButton.enabled, self.overlayButton.highlighted) {

        case (false, _):
            newText = "WAIT"
            
        case (_, true):
            newText = "ON AIR"
            
        case (_, false):
            newText = "HOLD \n&\n SPEAK"
            
        default:
            newText = ""
        }
        
        self.titleLabel.text = newText
    }

    func updateBackgroundColor() {
        if self.overlayButton.highlighted {
            self.backgroundColor = UIColor(red: 162.0/255, green: 21.0/255, blue: 1.0/255, alpha: 1)
        }
        else {
            self.backgroundColor = UIColor(red: 40.0/255, green: 90.0/255, blue: 145.0/255, alpha: 1)
        }
    }
    
    func addViewFromNib() {
        var views : [AnyObject] = NSBundle.mainBundle().loadNibNamed("SpeakButton", owner: self, options: nil)
        
        var view = views.first as UIView
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(view)
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: .allZeros, metrics: nil, views:[ "view" : view, "self" : self ]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: .allZeros, metrics: nil, views:[ "view" : view, "self" : self ]))
    }
    
    func didTouchDown(sender : AnyObject) {
        println("didTouchDown")
        
        UIView.beginAnimations("TouchDown", context: nil)
        
        self.overlayButton.highlighted = true
        self.updateBackgroundColor()
        self.updateTitleLabel()
        
        UIView.commitAnimations()
        
        delegate?.speakButtonWasTouched(self)
    }
    
    func didTouchUp(sender : AnyObject) {
        println("didTouchUp")
        
        UIView.beginAnimations("TouchUp", context: nil)

        self.overlayButton.highlighted = false
        self.updateBackgroundColor()
        self.updateTitleLabel()
        
        UIView.commitAnimations()
        
        delegate?.speakButtonWasReleased(self)
    }
}