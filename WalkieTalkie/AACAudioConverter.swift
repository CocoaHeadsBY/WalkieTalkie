//
//  AACAudioConverter.swift
//  WalkieTalkie
//
//  Created by Aliksandr Andrashuk on 18.10.14.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

import Foundation
import AVFoundation
import CoreAudio
import AudioToolbox

class AACAudioEncoder {
    
    var audioConverter : Unmanaged<AudioConverter>?;
    
    init (sourceFormat : UnsafePointer<AudioStreamBasicDescription>) {

    }
    
    func doConvert() {
        println("will encode to aac")
    }
}

class AACAudioDecoder {
    func doConvert() {
        println("will decode from aac")
    }
}