//
//  AudioEngine.swift
//  WalkieTalkie
//
//  Created by Cyril Lashkevich on 18.10.2014.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

import Foundation
import AVFoundation

public typealias CompressedDataClosure = (dataToSend: NSData) -> ()

public class AudioEngine: SessionContainerDelegate {
    var engine = AVAudioEngine()
    init() {
        let delayUnit = AVAudioUnitDelay()
        engine.attachNode(delayUnit)
        engine.connect(engine.inputNode, to:delayUnit, format: nil)
        engine.connect(delayUnit, to: engine.outputNode, format: nil)
        let outStreamDescription = engine.inputNode.outputFormatForBus(0).streamDescription
        var error: NSError?
        engine.startAndReturnError(&error)
        println(error)
    }

    public func startRecord(block: CompressedDataClosure) {
        engine.inputNode.installTapOnBus(AVAudioNodeBus(0), bufferSize: AVAudioFrameCount(1024), format: nil, block: {
            (buf: AVAudioPCMBuffer!, when: AVAudioTime!) -> Void in
            // compress
            // call block
        })
    }

    public func stopRecord() {
        engine.inputNode.removeTapOnBus(AVAudioNodeBus(0))
    }

    // SessionContainerDelegate implementation
    func sessionContainer(SessionContainer, didReceive data: NSData, peer peerID: protocol<NSObjectProtocol, NSCopying>) {

    }

    func sessionContainerDidUpdateListOfConnectedPeers(SessionContainer) {
        
    }
}
