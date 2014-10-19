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

let generalFormat = AVAudioFormat(standardFormatWithSampleRate: 8000, channels: 1)

class AudioPlayerDecoder {
    let audioPlayer = AVAudioPlayerNode()
    let decoder: AudioQueueDecoder;
    let buffer = AVAudioPCMBuffer(PCMFormat: generalFormat, frameCapacity: 8196)

    init () {
        decoder = AudioQueueDecoder(format: buffer.format.streamDescription)
    }

    func decodeAndPlay(data: NSData) {
        println("Received \(data.length)")
        decoder.decodeData(data, toBuffer: buffer)

        if (buffer.frameLength > 0) {
            audioPlayer.scheduleBuffer(buffer, completionHandler: { println("Frame played") })
        }
    }
}

public typealias CompressedDataClosure = (dataToSend: NSData!) -> ()

public class AudioEngine {
    let engine = AVAudioEngine()
    var peerToOutput = Dictionary<MCPeerID, AudioPlayerDecoder>()
    let recorder = AudioQueueRecorder()

    init() {
        var error : NSError?;

        setupAudioSession()
        disableAUIO()

        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: generalFormat)
        engine.startAndReturnError(&error)

        if error != nil {
            println("Error when running engine")
            println(error)
        }
    }

    deinit {
        engine.stop()
        stopAudioSession()
    }

    public func startRecord(block: CompressedDataClosure) {
        recorder.dataProducedBlock = block;
        recorder.start();
    }

    public func stopRecord() {
        recorder.stop()
    }

    func didReceive(data: NSData, fromPeer peerID: MCPeerID) {
        peerToOutput[peerID]?.decodeAndPlay(data)
    }

    func peerConnected(peerID: MCPeerID) {
        let playerDecoder = AudioPlayerDecoder()
        engine.attachNode(playerDecoder.audioPlayer)
        engine.connect(playerDecoder.audioPlayer, to: engine.mainMixerNode, format: generalFormat)
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

    private func setupAudioSession () {

        var error : NSError?;
        let auSession = AVAudioSession.sharedInstance()
        auSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker, error: &error)
        if error != nil {
            println("Error when setting up audio session")
            println(error)
        }

        auSession.setMode(AVAudioSessionModeVoiceChat, error: &error)
        if error != nil {
            println("Error when setting up audio session")
            println(error)
        }

        auSession.setActive(true, withOptions: AVAudioSessionSetActiveOptions.OptionNotifyOthersOnDeactivation, error: &error)
        if error != nil {
            println("Error when setting up audio session")
            println(error)
        }

        auSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: &error)
        if error != nil {
            println("Error when setting up audio session")
            println(error)
        }

    }

    private func stopAudioSession () {
        AVAudioSession.sharedInstance().setActive(false, error: nil)
    }

    private func disableAUIO () {
        var disabled : UInt32 = 0;
        let err = AudioUnitSetProperty(engine.inputNode.audioUnit,
            AudioUnitPropertyID(kAudioOutputUnitProperty_EnableIO),
            AudioUnitScope(kAudioUnitScope_Input), 1, &disabled, UInt32(sizeof(UInt32)))

        assert(err == noErr, "Cannot disable input")
    }
}
