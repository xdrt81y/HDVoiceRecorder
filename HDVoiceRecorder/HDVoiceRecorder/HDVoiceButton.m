//
//  HDVoiceButton.m
//  HDVoiceRecorder
//
//  Created by haidi han on 2018/11/23.
//  Copyright © 2018 haidi han. All rights reserved.
//

#import "HDVoiceButton.h"
#import "UUAVAudioPlayer.h"

@interface HDVoiceButton () <UUAVAudioPlayerDelegate>

@property (nonatomic, strong) UUAVAudioPlayer* player;
@property (nonatomic, strong) UIImageView* iconView;
@property (nonatomic, strong) UIActivityIndicatorView* indicator;

@end

@implementation HDVoiceButton

- (instancetype)initWithStyle:(enum VoicePlayButtonStyle)style {
    self = [super init];
    if (self) {
        self.style = style;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.iconView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.iconView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.iconView.contentMode = UIViewContentModeScaleToFill;
        self.iconView.animationDuration = 1.0;
        self.iconView.animationRepeatCount = 0;
        [self addSubview:self.iconView];
        
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicator.center = self.center;
        self.indicator.hidesWhenStopped = YES;
        self.indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.indicator];
        
        self.iconView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        
        self.style = VPStyleLight;
        
        self.player = [[UUAVAudioPlayer alloc] init];
        self.player.delegate = self;
    }
    return self;
}

- (void)setStyle:(enum VoicePlayButtonStyle)style {
    _style = style;
    
    //获取图片资源
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"HDVoiceRecorder" ofType:@"bundle"]];
    
    if (style == VPStyleLight) {
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        self.iconView.image = [UIImage imageNamed:@"chatto_voice_playing_f3" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        self.iconView.animationImages = @[[UIImage imageNamed:@"chatto_voice_playing_f1" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
                                          [UIImage imageNamed:@"chatto_voice_playing_f2" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
                                          [UIImage imageNamed:@"chatto_voice_playing_f3" inBundle:resourcesBundle compatibleWithTraitCollection:nil]];
    }
    else {
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.iconView.image = [UIImage imageNamed:@"chatfrom_voice_playing_f3" inBundle:resourcesBundle compatibleWithTraitCollection:nil];
        self.iconView.animationImages = @[[UIImage imageNamed:@"chatfrom_voice_playing_f1" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
                                          [UIImage imageNamed:@"chatfrom_voice_playing_f2" inBundle:resourcesBundle compatibleWithTraitCollection:nil],
                                          [UIImage imageNamed:@"chatfrom_voice_playing_f3" inBundle:resourcesBundle compatibleWithTraitCollection:nil]];
    }
}

- (void)playUrl:(NSURL*)url {
    
    if (!self.isPlaying) {
        [self.player playSongWithUrl:url];
    }
}

- (void)playData:(NSData*)data {
    
    if (!self.isPlaying) {
        [self.player playSongWithData:data];
    }
}

- (BOOL)isPlaying {
    return self.player.isPlaying;
}

- (void)stopPlaying {
    [self.player stopSound];
    [self UUAVAudioPlayerDidFinishPlay];
}

#pragma mark - UUAVAudioPlayerDelegate

- (void)UUAVAudioPlayerBeiginLoadVoice {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicator startAnimating];
        self.indicator.hidden = NO;
        self.iconView.hidden = YES;
    });
}

- (void)UUAVAudioPlayerDidLoadedVoice {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicator stopAnimating];
        self.indicator.hidden = YES;
        self.iconView.hidden = NO;
    });
}

- (void)UUAVAudioPlayerBeiginPlay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.indicator stopAnimating];
        self.indicator.hidden = YES;
        self.iconView.hidden = NO;
        [self.iconView startAnimating];
    });
}

- (void)UUAVAudioPlayerDidFinishPlay {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.indicator.hidden = YES;
        self.iconView.hidden = NO;
        [self.iconView stopAnimating];
    });
}

@end
