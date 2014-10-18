//
//  AudioQueue.h
//  WalkieTalkie
//
//  Created by Cyril Lashkevich on 18.10.2014.
//  Copyright (c) 2014 CocoaHeadsBY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioQueueRecorder : NSObject

@property (strong) void (^dataProducedBlock)(NSData *data);

- (instancetype)init;
- (void)start;
- (void)stop;


@end
