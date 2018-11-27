//
//  HDVoiceButton.h
//  HDVoiceRecorder
//
//  Created by haidi han on 2018/11/23.
//  Copyright © 2018 haidi han. All rights reserved.
//

#import <UIKit/UIKit.h>
enum VoicePlayButtonStyle {
    VPStyleLight,
    VPStyleDark,
};

// 声音播放按钮
@interface HDVoiceButton : UIButton

// style，默认是Light
@property (nonatomic, assign) enum VoicePlayButtonStyle style;

- (instancetype)initWithStyle:(enum VoicePlayButtonStyle)style;

- (void)playUrl:(NSURL*)url;

- (void)playData:(NSData*)data;

- (BOOL)isPlaying;

- (void)stopPlaying;

@end
