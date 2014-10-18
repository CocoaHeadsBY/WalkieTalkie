//
//  AudioQueue.m
//  WalkieTalkie
//
//  Created by Cyril Lashkevich on 18.10.2014.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

#import "AudioQueue.h"
#include <AudioToolbox/AudioToolbox.h>

static const AudioStreamBasicDescription asbdAAC = {
    .mSampleRate = 220150.,
    .mFormatID = kAudioFormatMPEG4AAC_ELD_V2,
    .mFormatFlags = 0,
    .mBytesPerPacket = 0,
    .mFramesPerPacket = 1024,
    .mBytesPerFrame = 0,
    .mChannelsPerFrame = 1,
    .mBitsPerChannel = 16,
    .mReserved = 0
};

@interface AudioQueueRecorder () {
    AudioQueueRef inputQueue;
    AudioQueueBufferRef	aqBuffers[3];
}

- (void)queueInputBuffer:(AudioQueueBufferRef)buffer startTime:(const AudioTimeStamp *)startTime numberPackets:(UInt32)numberPackets packetDescs:(const AudioStreamPacketDescription *)descs;

@end


static void audioQueueInputCallback(void *                          inUserData,
                                    AudioQueueRef                   inAQ,
                                    AudioQueueBufferRef             inBuffer,
                                    const AudioTimeStamp *          inStartTime,
                                    UInt32                          inNumberPacketDescriptions,
                                    const AudioStreamPacketDescription *inPacketDescs) {
    AudioQueueRecorder *recorder = (__bridge AudioQueueRecorder *)inUserData;
    [recorder queueInputBuffer:inBuffer startTime:inStartTime numberPackets:inNumberPacketDescriptions packetDescs:inPacketDescs];
}

@implementation AudioQueueRecorder

- (instancetype)init {
    if (self = [super init]) {
        OSStatus st = AudioQueueNewInput(
                           &asbdAAC,
                           audioQueueInputCallback,
                           (__bridge void*)self,
                           NULL /* run loop */, NULL /* run loop mode */,
                           0 /* flags */, &inputQueue);
        NSAssert(st == noErr, @"st = &d", st);
        AudioStreamBasicDescription recordFormat;
        st = AudioQueueGetProperty(inputQueue, kAudioQueueProperty_StreamDescription,
                                   &recordFormat, &(UInt32){sizeof(AudioStreamBasicDescription)});
        NSAssert(st == noErr, @"st = &d", st);
        for (int i = 0; i < 3; ++i) {
            st = AudioQueueAllocateBuffer(inputQueue, 1024, &aqBuffers[i]);
            NSAssert(st == noErr, @"AudioQueueAllocateBuffer failed with err %d", st);
            st = AudioQueueEnqueueBuffer(inputQueue, aqBuffers[i], 0, NULL);
            NSAssert(st == noErr, @"AudioQueueEnqueueBuffer failed with err %d", st);
        }
    }
    return self;
}

- (void)start {
    AudioQueueFlush(inputQueue);
    OSStatus st = AudioQueueStart(inputQueue, NULL);
    NSAssert(st == noErr, @"st = &d", st);
}

- (void)stop {
    OSStatus st = AudioQueueStop(inputQueue, false);
    NSAssert(st == noErr, @"st = &d", st);
}

- (void)queueInputBuffer:(AudioQueueBufferRef)buffer startTime:(const AudioTimeStamp *)startTime numberPackets:(UInt32)numberPackets packetDescs:(const AudioStreamPacketDescription *)descs {

}

@end
