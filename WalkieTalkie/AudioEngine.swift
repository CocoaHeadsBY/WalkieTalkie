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

var asbd = AudioStreamBasicDescription(mSampleRate: 44100,
    mFormatID: AudioFormatID(kAudioFormatLinearPCM),
    mFormatFlags: AudioFormatFlags(kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian),
    mBytesPerPacket: 4,
    mFramesPerPacket: 1,
    mBytesPerFrame: 4,
    mChannelsPerFrame: 2,
    mBitsPerChannel: 16,
    mReserved: 0)

let generalFormat = AVAudioFormat(streamDescription: &asbd)

class AudioPlayerDecoder {
    let audioPlayer = AVAudioPlayerNode()
    let decoder: AudioQueueDecoder;
    let buffer = AVAudioPCMBuffer(PCMFormat: generalFormat, frameCapacity: 64)

    init () {
        decoder = AudioQueueDecoder(format: buffer.format.streamDescription)
    }

    func decodeAndPlay(data: NSData) {

        println("Received \(data.length)")

        var localBuffer = AVAudioPCMBuffer(PCMFormat: generalFormat, frameCapacity: 128)
//        decoder.decodeData(data, toBuffer: localBuffer)

        println("will play buffer \(buffer)")

        if (localBuffer.frameLength > 0) {
//            audioPlayer.scheduleBuffer(localBuffer, completionHandler: { println("Frame played") })
        }
    }
}

public typealias CompressedDataClosure = (dataToSend: NSData!) -> ()

public class AudioEngine {
    let engine = AVAudioEngine()
    var peerToOutput = Dictionary<MCPeerID, AudioPlayerDecoder>()
    let recorder = AudioQueueRecorder()
    var auPlayer : AVAudioPlayer

    init() {
        var error : NSError?;

        var soundUrl = NSBundle.mainBundle().URLForResource("noise", withExtension: "mp3")
        auPlayer = AVAudioPlayer(contentsOfURL: soundUrl, error: nil)

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
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.auPlayer.playing == false {
                self.auPlayer.play()
            }
        });

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
