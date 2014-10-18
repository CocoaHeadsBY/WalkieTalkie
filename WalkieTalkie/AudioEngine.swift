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
        let buffer = AVAudioPCMBuffer()

        audioPlayer.scheduleBuffer(buffer, completionHandler: {})
    }
}

public typealias CompressedDataClosure = (dataToSend: NSData!) -> ()

public class AudioEngine: PeerCommunicationDelegate {
    let engine = AVAudioEngine()
    var peerToOutput = Dictionary<MCPeerID, AudioPlayerDecoder>()
    let recorder = AudioQueueRecorder()

    init() {

    }

    public func startRecord(block: CompressedDataClosure) {
        recorder.dataProducedBlock = block;
        recorder.start();
    }

    public func stopRecord() {
        recorder.stop()
    }

    // PeerCommunicationDelegate implementation
    func didReceive(data: NSData, fromPeer peerID: MCPeerID) {
        peerToOutput[peerID]?.decodeAndPlay(data)
    }

    func peerConnected(peerID: MCPeerID) {
        let playerDecoder = AudioPlayerDecoder()
        //engine.attachNode(playerDecoder.audioPlayer)
        //engine.connect(playerDecoder.audioPlayer, to: engine.mainMixerNode, format: nil)
        //playerDecoder.audioPlayer.play()
        //peerToOutput[peerID] = playerDecoder
    }

    func peerDisconnected(peerID: MCPeerID) {
        if let playerDecoder = peerToOutput[peerID] {
            engine.disconnectNodeOutput(playerDecoder.audioPlayer)
            engine.detachNode(playerDecoder.audioPlayer)
            peerToOutput.removeValueForKey(peerID)
        }
    }

}
