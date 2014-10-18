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
    
    var audioConverter : Unmanaged<AudioConverter>?
    var outputFormat : AudioStreamBasicDescription
    
    init (sourceFormat : UnsafePointer<AudioStreamBasicDescription>) {

        outputFormat = AudioStreamBasicDescription(mSampleRate: 44100.0,
            mFormatID: AudioFormatID(kAudioFormatMPEG4AAC),
            mFormatFlags: 0,
            mBytesPerPacket: 0,
            mFramesPerPacket: 0,
            mBytesPerFrame: 0,
            mChannelsPerFrame: 1,
            mBitsPerChannel: 0,
            mReserved: 0)

        
        var err = AudioConverterNew(sourceFormat, &outputFormat, &audioConverter)
        
        assert( err == noErr, "cannot init convertor" )
        
//        setUpProperties()
    }
    
    deinit {
//        AudioConverterDispose(audioConverter?.takeUnretainedValue())
    }
    
    func setUpProperties () {

        var bitrate : UInt32 = 16000;
        let bitrateSize : UInt32 = UInt32(sizeof(UInt32))
        var err = noErr;

        err = AudioConverterSetProperty(audioConverter?.takeUnretainedValue(),
                AudioConverterPropertyID(kAudioConverterEncodeBitRate),
                bitrateSize,
                &bitrate)

        assert( err == noErr, "cannot set encode bitrate")

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