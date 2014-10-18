//
//  SpeakButton.swift
//  WalkieTalkie
//
//  Created by Konstantin Salak on 18/10/14.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

import Foundation
import UIKit

protocol SpeakButtonDelegate : class {
    
    func speakButtonWasTouched(speakButton: SpeakButton)
    func speakButtonWasReleased(speakButton: SpeakButton)
}

class SpeakButton : UIView {

    @IBOutlet weak var overlayButton : UIButton!
    
    weak var delegate : SpeakButtonDelegate?

    func linkEvents(){

        self.overlayButton.addTarget(self, action: "didTouchDown:", forControlEvents: .TouchDown)
        self.overlayButton.addTarget(self, action: "didTouchUp:", forControlEvents: .TouchUpInside)
        self.overlayButton.addTarget(self, action: "didTouchUp:", forControlEvents: .TouchUpOutside)
    }
    
    func commonInit(){
        self.linkEvents()
        
        self.layer.cornerRadius = 10.0;
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    override func awakeFromNib() {
        
        self.addViewFromNib()
        self.commonInit()
        
        
    }
    
    /*
    UIView* detailsView = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] lastObject];
    
    detailsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:detailsView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[detailsView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(detailsView, self)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[detailsView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(detailsView, self)]];
    
    [self addSubview:detailsView];
*/
    
    func addViewFromNib(){
        
        var views : [AnyObject] = NSBundle.mainBundle().loadNibNamed("SpeakButton", owner: self, options: nil)
        
        var view = views.first as UIView
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(view)
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options: .allZeros, metrics: nil, views:[ "view" : view, "self" : self ]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: .allZeros, metrics: nil, views:[ "view" : view, "self" : self ]))
    }
    
    func didTouchDown(sender : AnyObject){
        
        println("didTouchDown")
        
        UIView.beginAnimations("TouchDown", context: nil)
        
        self.backgroundColor = UIColor(red: 20.0/255, green: 148.0/255, blue: 73.0/255, alpha: 1)
        
        UIView.commitAnimations()
        
        delegate?.speakButtonWasTouched(self)
    }
    
    func didTouchUp(sender : AnyObject){
        
        println("didTouchUp")
        
        UIView.beginAnimations("TouchUp", context: nil)
        
        self.backgroundColor = UIColor(red: 162.0/255, green: 21.0/255, blue: 1.0/255, alpha: 1)
        UIView.commitAnimations()
        
        delegate?.speakButtonWasReleased(self)
    }
}