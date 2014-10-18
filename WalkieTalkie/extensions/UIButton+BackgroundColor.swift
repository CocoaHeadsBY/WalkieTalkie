//
//  UIButton+BackgroundColor.swift
//  WalkieTalkie
//
//  Created by Konstantin Salak on 18/10/14.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

import Foundation
import UIKit

//extension UIButton {
//    
//    func setBackgroundColour(color: UIColor?, forState state: UIControlState){
//        
//        func imageFromColor (color: UIColor?) -> UIImage? {
//            var image : UIImage
//            var rect : CGRect = CGRectMake(0, 0, 1, 1)
//            UIGraphicsBeginImageContext(rect.size)
//            
//            var context : CGContextRef = UIGraphicsGetCurrentContext()
//            CGContextSetFillColorWithColor(context, color?.CGColor)
//            CGContextFillRect(context, rect)
//            image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            
//            return image
//        }
//        
//        let img = imageFromColor(color)
//        self.setBackgroundImage(img, forState: state)
//        
//    }
//    
//}