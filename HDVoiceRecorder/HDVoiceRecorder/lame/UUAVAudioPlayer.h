//
//  UUAVAudioPlayer.h
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>


@protocol UUAVAudioPlayerDelegate <NSObject>

- (void)UUAVAudioPlayerBeiginLoadVoice;
- (void)UUAVAudioPlayerBeiginPlay;
- (void)UUAVAudioPlayerDidFinishPlay;

@optional
- (void)UUAVAudioPlayerDidLoadedVoice;

@end

@interface UUAVAudioPlayer : NSObject
@property (nonatomic, assign)id <UUAVAudioPlayerDelegate>delegate;
+ (UUAVAudioPlayer *)sharedInstance;

- (void)playSongWithUrl:(NSURL *)fileUrl;
- (void)playSongWithData:(NSData *)songData;

- (void)stopSound;

- (BOOL)isPlaying;

@end
