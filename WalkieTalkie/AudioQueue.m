//
//  AudioQueue.m
//  WalkieTalkie
//
//  Created by Cyril Lashkevich on 18.10.2014.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

#import "AudioQueue.h"

#define NUMBER_OF_CHANNELS 2

static AudioStreamBasicDescription asbdAAC = {
    .mSampleRate = 44100,
    .mFormatID = kAudioFormatLinearPCM,
    .mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian,
    .mBytesPerPacket = 4,
    .mFramesPerPacket = 1,
    .mBytesPerFrame = 4,
    .mChannelsPerFrame = NUMBER_OF_CHANNELS,
    .mBitsPerChannel = 16,
    .mReserved = 0
};

static const AudioChannelLayout channelLayout = {
    .mChannelLayoutTag = kAudioChannelLayoutTag_Mono
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

- (void)dealloc {
    AudioQueueDispose(inputQueue, TRUE);
}

- (instancetype)init {
    if (self = [super init]) {
        AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                               0,
                               NULL,
                               &((UInt32){ sizeof(asbdAAC)}),
                               &asbdAAC);

        OSStatus st = AudioQueueNewInput(
                           &asbdAAC,
                           audioQueueInputCallback,
                           (__bridge void*)self,
                           NULL /* run loop */, NULL /* run loop mode */,
                           0 /* flags */, &inputQueue);
        NSAssert(st == noErr, @"st = %d", (int)st);
        for (int i = 0; i < 3; ++i) {
            st = AudioQueueAllocateBuffer(inputQueue, 256, &aqBuffers[i]);
            NSAssert(st == noErr, @"AudioQueueAllocateBuffer failed with err %d", (int)st);
            st = AudioQueueEnqueueBuffer(inputQueue, aqBuffers[i], 0, NULL);
            NSAssert(st == noErr, @"AudioQueueEnqueueBuffer failed with err %d", (int)st);
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
    if (_dataProducedBlock && buffer->mAudioDataByteSize) {
        NSMutableData *ts = [NSMutableData dataWithBytes:(void *)&startTime->mSampleTime length:sizeof(startTime->mSampleTime)];
        [ts appendBytes:buffer->mAudioData length:buffer->mAudioDataByteSize];
        _dataProducedBlock(ts);
    }
    AudioQueueEnqueueBuffer(inputQueue, buffer, 0, NULL);
}

@end


@interface AudioQueueDecoder () {
    AudioQueueRef decoderQueue;
    AudioQueueBufferRef	inputBuffer;
    AudioQueueBufferRef	outputBuffer;
}

- (void)queueOutputBuffer:(AudioQueueBufferRef)buffer;

@end

static void audioQueueOutputCallback(void *                  inUserData,
                                     AudioQueueRef           inAQ,
                                     AudioQueueBufferRef     inBuffer) {
    AudioQueueDecoder *decoder = (__bridge AudioQueueDecoder *)inUserData;
    [decoder queueOutputBuffer:inBuffer];
}

@implementation AudioQueueDecoder

- (void)dealloc {
    [self stop];
    AudioQueueDispose(decoderQueue, true);
}

- (instancetype)initWithFormat:(AudioStreamBasicDescription const *)format {
    if (self = [super init]) {
        OSStatus st = AudioQueueNewOutput(&asbdAAC,
                                          audioQueueOutputCallback,
                                          (__bridge void*)self,
                                          NULL /* run loop */, NULL /* run loop mode */,
                                          0 /* flags */, &decoderQueue);
        NSAssert(st == noErr, @"st = %d", (int)st);
        st = AudioQueueAllocateBuffer(decoderQueue, 8196, &inputBuffer);
        NSAssert(st == noErr, @"AudioQueueAllocateBuffer failed with err %d", (int)st);
        st = AudioQueueAllocateBuffer(decoderQueue, 8196, &outputBuffer);
        NSAssert(st == noErr, @"AudioQueueAllocateBuffer failed with err %d", (int)st);

        st = AudioQueueSetOfflineRenderFormat(decoderQueue, format, &channelLayout);
        NSAssert(st == noErr, @"AudioQueueSetOfflineRenderFormat st = %d", (int)st);

        st = AudioQueueStart(decoderQueue, NULL);
        NSAssert(st == noErr, @"AudioQueueStart st = %d", (int)st);

        AudioTimeStamp ts;
        ts.mFlags = kAudioTimeStampSampleTimeValid;
        ts.mSampleTime = 0;
        st = AudioQueueOfflineRender(decoderQueue, &ts, outputBuffer, 0);
        NSAssert(st == noErr, @"AudioQueueOfflineRender st = %d", (int)st);
    }
    return self;
}

- (void)stop {
    AudioQueueFlush(decoderQueue);
    AudioQueueStop(decoderQueue, false);
}

- (void)decodeData:(NSData *)data toBuffer:(AVAudioPCMBuffer *)buffer {
    
//    [data getBytes:buffer.mutableAudioBufferList->mBuffers[0].mData range:NSMakeRange(sizeof(Float64), data.length - sizeof(Float64))];
    
    memcpy(buffer.mutableAudioBufferList->mBuffers[0].mData, data.bytes, data.length - sizeof(Float64));
    buffer.mutableAudioBufferList->mBuffers[0].mNumberChannels = 2;
    buffer.mutableAudioBufferList->mBuffers[0].mDataByteSize = 32 * 4;
    buffer.frameLength = 32;
    
    return;

    [data getBytes:buffer.mutableAudioBufferList->mBuffers[0].mData range:NSMakeRange(sizeof(Float64), data.length - sizeof(Float64))];
    buffer.frameLength = (data.length - sizeof(Float64)) / 4;
    buffer.mutableAudioBufferList->mBuffers[0].mNumberChannels = NUMBER_OF_CHANNELS;

    return;

    AudioTimeStamp ts;
    ts.mSampleTime = *((Float64 *)data.bytes);
    ts.mFlags = kAudioTimeStampSampleTimeValid;

    inputBuffer->mAudioDataByteSize = (UInt32)(data.length - sizeof(Float64));
    [data getBytes:inputBuffer->mAudioData range:NSMakeRange(sizeof(Float64), inputBuffer->mAudioDataByteSize)];

    OSStatus st = AudioQueueOfflineRender(decoderQueue, &ts, outputBuffer, 64);
    NSLog(@"Decoded bytes %d", outputBuffer->mAudioDataByteSize);
    memcpy(buffer.mutableAudioBufferList->mBuffers[0].mData, outputBuffer->mAudioData, outputBuffer->mAudioDataByteSize);
    buffer.mutableAudioBufferList->mBuffers[0].mDataByteSize = outputBuffer->mAudioDataByteSize;
    buffer.frameLength = outputBuffer->mAudioDataByteSize / 4;

    NSAssert(st == noErr, @"AudioQueueOfflineRender failed with err %d", (int)st);
}

- (void)queueOutputBuffer:(AudioQueueBufferRef)buffer {
    AudioStreamPacketDescription packetDescription = {
        .mStartOffset = 0, 
        .mVariableFramesInPacket = 0,
        .mDataByteSize = inputBuffer->mAudioDataByteSize
    };
    OSStatus st = AudioQueueEnqueueBuffer(decoderQueue, inputBuffer, (inputBuffer->mAudioDataByteSize - 8) / 50, NULL);
    NSAssert(st == noErr, @"AudioQueueEnqueueBuffer failed with err %d", (int)st);
}

@end

