//
//  AVAudioSession+External.m
//  BIM
//
//  Created by hanhd on 2017/10/13.
//  Copyright © 2017年 adidas. All rights reserved.
//

#import "AVAudioSession+External.h"

@implementation AVAudioSession (External)

+ (BOOL) isExternalAudioPlaying{
    return [AVAudioSession sharedInstance].otherAudioPlaying;
}

+ (void)recoverExternalPlaying{
    [[AVAudioSession sharedInstance] setActive:NO
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:nil];
}

@end
