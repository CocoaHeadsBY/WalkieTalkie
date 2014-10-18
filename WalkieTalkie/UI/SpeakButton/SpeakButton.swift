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

class SpeakButton : UIButton {
    
    weak var delegate : SpeakButtonDelegate?

    func linkEvents(){
        
        self.addTarget(self, action: "didTouchDown:", forControlEvents: .TouchDown)
        self.addTarget(self, action: "didTouchUp:", forControlEvents: .TouchUpInside)
        self.addTarget(self, action: "didTouchUp:", forControlEvents: .TouchUpOutside)
    }
    
    func commonInit(){
        self.linkEvents()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }

    
    func didTouchDown(sender : AnyObject){
        
        println("didTouchDown")
        
        delegate?.speakButtonWasTouched(self)
    }
    
    func didTouchUp(sender : AnyObject){
        
        println("didTouchUp")
        
        delegate?.speakButtonWasReleased(self)
    }
}