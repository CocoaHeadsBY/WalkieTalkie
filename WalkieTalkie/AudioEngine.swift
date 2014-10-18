//
//  AudioEngine.swift
//  WalkieTalkie
//
//  Created by Cyril Lashkevich on 18.10.2014.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

import Foundation
import AVFoundation
import MultipeerConnectivity

class AudioPlayerDecoder {
    var audioPlayer = AVAudioPlayerNode()
    func decodeAndPlay(data: NSData) {
    }
}

public typealias CompressedDataClosure = (dataToSend: NSData) -> ()

public class AudioEngine: PeerCommunicationDelegate {
    let engine = AVAudioEngine()
    var peerToOutput = Dictionary<MCPeerID, AudioPlayerDecoder>()

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

    // PeerCommunicationDelegate implementation
    func didReceive(data: NSData, fromPeer peerID: MCPeerID) {
        peerToOutput[peerID]?.decodeAndPlay(data)
    }

    func peerConnected(peerID: MCPeerID) {
        let playerDecoder = AudioPlayerDecoder()
        engine.attachNode(playerDecoder.audioPlayer)
        engine.connect(playerDecoder.audioPlayer, to: engine.mainMixerNode, format: nil)
        playerDecoder.audioPlayer.play()
        peerToOutput[peerID] = playerDecoder
    }

    func peerDisconnected(peerID: MCPeerID) {
        if let playerDecoder = peerToOutput[peerID] {
            engine.disconnectNodeOutput(playerDecoder.audioPlayer)
            engine.detachNode(playerDecoder.audioPlayer)
            peerToOutput.removeValueForKey(peerID)
        }
    }

}
