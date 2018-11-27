//
//  AVAudioSession+External.h
//  BIM
//
//  Created by hanhd on 2017/10/13.
//  Copyright © 2017年 adidas. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAudioSession (External)

+ (BOOL) isExternalAudioPlaying;

+ (void) recoverExternalPlaying;

@end
