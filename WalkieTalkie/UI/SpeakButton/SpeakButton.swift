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

@objc protocol SpeakButtonProtocol{
    
    func didReceiveSoundAtLevel(level : Float)
}


enum TransmitterState{
    case
    NotAvailable,
    Idle,
    Sending,
    Receiving
}


class SpeakButton : UIView, SpeakButtonProtocol {
    
    @IBOutlet weak var overlayButton : UIButton!
    @IBOutlet weak var delegate: SpeakButtonDelegate?
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var pulsar: PulseCircle!
    
    var transmitterState: TransmitterState {
        didSet{
            println(transmitterState)
            self.pulsar.transmitterState = transmitterState
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        transmitterState = .NotAvailable
        super.init(coder: aDecoder)
    }
    
    var enabled : Bool {
        get{
            return overlayButton.enabled
        }
        set{
            overlayButton.enabled = newValue
            self.transmitterState = newValue ? .Idle : .NotAvailable
            
            self.updateTitleLabel()
            self.updateBackgroundColor()
        }
    }
    
    func tryToSetTransmitterState(newState : TransmitterState){
        
        switch (self.transmitterState, newState){
        case (.NotAvailable, _):
            break
        case (.Sending, .Receiving):
            break
        default:
            self.transmitterState = newState
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
        
        switch self.transmitterState {
        case .NotAvailable:
            newText = "WAIT"
        case .Sending :
            newText = "ON AIR"
        case .Idle :
            newText = "HOLD\n&\nSPEAK"
        case .Receiving:
            newText = ""
        }
        
        self.titleLabel.text = newText
    }

    func updateBackgroundColor() {
        
        var backColor : UIColor
        
        switch self.transmitterState {
        case .NotAvailable:
            backColor = UIColor.lightGrayColor()
        case .Sending :
            backColor = UIColor(red: 162.0/255, green: 21.0/255, blue: 1.0/255, alpha: 1)
        case .Idle :
            backColor = UIColor(red: 40.0/255, green: 90.0/255, blue: 145.0/255, alpha: 1)
        case .Receiving:
            backColor = UIColor(red: 41/255, green: 146.0/255, blue: 58.0/255, alpha: 1)
        }
        
        self.backgroundColor = backColor
        self.pulsar.circleColor = backColor
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
        
        self.tryToSetTransmitterState(.Sending)
        
        UIView.beginAnimations("TouchDown", context: nil)
        
        self.overlayButton.highlighted = true
        self.updateBackgroundColor()
        self.updateTitleLabel()
        
        UIView.commitAnimations()
        
        delegate?.speakButtonWasTouched(self)
    }
    
    func didTouchUp(sender : AnyObject) {
        println("didTouchUp")
        
        self.tryToSetTransmitterState(.Idle)
        
        UIView.beginAnimations("TouchUp", context: nil)

        self.overlayButton.highlighted = false
        self.updateBackgroundColor()
        self.updateTitleLabel()
        
        UIView.commitAnimations()
        
        delegate?.speakButtonWasReleased(self)
    }
    
    func didReceiveSoundAtLevel(level : Float) {
        
        self.tryToSetTransmitterState(.Receiving)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.updateBackgroundColor()
            self.updateTitleLabel()
            
        }) { (_) -> Void in
            self.updateBackgroundColor()
            self.updateTitleLabel()
        }
        
    }
}