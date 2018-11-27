//
//  HDVoiceProgressHUD.m
//  HDVoiceRecorder
//
//  Created by haidi han on 2018/11/23.
//  Copyright © 2018 haidi han. All rights reserved.
//

#import "HDVoiceProgressHUD.h"

@interface HDVoiceProgressHUD()

@property (nonatomic, strong) NSTimer * myTimer;
@property (nonatomic, assign) int angle;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UIImageView *edgeImageView;
@property (nonatomic, strong, readonly) UIWindow *overlayWindow;

@end

@implementation HDVoiceProgressHUD

@synthesize overlayWindow;

+ (HDVoiceProgressHUD*)sharedView {
    static dispatch_once_t once;
    static HDVoiceProgressHUD *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[HDVoiceProgressHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        sharedView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    });
    return sharedView;
}

+ (void)show {
    [[HDVoiceProgressHUD sharedView] show];
}

- (void)show {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!weakSelf.superview)
            [weakSelf.overlayWindow addSubview:self];
        
        if (!weakSelf.centerLabel){
            weakSelf.centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
            weakSelf.centerLabel.backgroundColor = [UIColor clearColor];
        }
        
        if (!weakSelf.subTitleLabel){
            weakSelf.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            weakSelf.subTitleLabel.backgroundColor = [UIColor clearColor];
        }
        if (!weakSelf.titleLabel){
            weakSelf.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            weakSelf.titleLabel.backgroundColor = [UIColor clearColor];
        }
        if (!weakSelf.edgeImageView){
            //获取图片资源
            NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
            NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"HDVoiceRecorder" ofType:@"bundle"]];
            weakSelf.edgeImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_record_circle" inBundle:resourcesBundle compatibleWithTraitCollection:nil]];
        }
        
        
        weakSelf.subTitleLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2 + 30);
        weakSelf.subTitleLabel.text = @"手指上滑，取消录音";
        weakSelf.subTitleLabel.textAlignment = NSTextAlignmentCenter;
        weakSelf.subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        weakSelf.subTitleLabel.textColor = [UIColor whiteColor];
        
        weakSelf.titleLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2 - 30);
        weakSelf.titleLabel.text = @"时间限制";
        weakSelf.titleLabel.textAlignment = NSTextAlignmentCenter;
        weakSelf.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        weakSelf.titleLabel.textColor = [UIColor whiteColor];
        
        weakSelf.centerLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2);
        weakSelf.centerLabel.text = @"60 秒";
        weakSelf.centerLabel.textAlignment = NSTextAlignmentCenter;
        weakSelf.centerLabel.font = [UIFont systemFontOfSize:30];
        weakSelf.centerLabel.textColor = [UIColor yellowColor];
        
        
        weakSelf.edgeImageView.frame = CGRectMake(0, 0, 154, 154);
        weakSelf.edgeImageView.center = weakSelf.centerLabel.center;
        [weakSelf addSubview:weakSelf.edgeImageView];
        [weakSelf addSubview:weakSelf.centerLabel];
        [weakSelf addSubview:weakSelf.subTitleLabel];
        [weakSelf addSubview:weakSelf.titleLabel];
        
        if (_myTimer)
            [_myTimer invalidate];
        _myTimer = nil;
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                   target:self
                                                 selector:@selector(startAnimation)
                                                 userInfo:nil
                                                  repeats:YES];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
        [self setNeedsDisplay];
    });
}
-(void) startAnimation
{
    self.angle -= 3;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.09];
    UIView.AnimationRepeatAutoreverses = YES;
    self.edgeImageView.transform = CGAffineTransformMakeRotation(self.angle * (M_PI / 180.0f));
    float second = [self.centerLabel.text floatValue];
    if (second <= 10.0f) {
        self.centerLabel.textColor = [UIColor redColor];
    }else{
        self.centerLabel.textColor = [UIColor yellowColor];
    }
    self.centerLabel.text = [NSString stringWithFormat:@"%.1f 秒",second-0.1];
    [UIView commitAnimations];
}

+ (void)changeSubTitle:(NSString *)str
{
    [[HDVoiceProgressHUD sharedView] setState:str];
}

- (void)setState:(NSString *)str
{
    self.subTitleLabel.text = str;
}

+ (void)dismissWithSuccess:(NSString *)str {
    [[HDVoiceProgressHUD sharedView] dismiss:str];
}

+ (void)dismissWithError:(NSString *)str {
    [[HDVoiceProgressHUD sharedView] dismiss:str];
}

- (void)dismiss:(NSString *)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_myTimer invalidate];
        _myTimer = nil;
        self.subTitleLabel.text = nil;
        self.titleLabel.text = nil;
        
        self.centerLabel.text = state;
        self.centerLabel.textColor = [UIColor whiteColor];
        
        CGFloat timeLonger;
        if ([state isEqualToString:@"TooShort"]) {
            timeLonger = 1;
        }else{
            timeLonger = 0.6;
        }
        [UIView animateWithDuration:timeLonger
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             if(self.alpha == 0) {
                                 [self.centerLabel removeFromSuperview];
                                 self.centerLabel = nil;
                                 [self.edgeImageView removeFromSuperview];
                                 self.edgeImageView = nil;
                                 [self.subTitleLabel removeFromSuperview];
                                 self.subTitleLabel = nil;
                                 
                                 NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                                 [windows removeObject:overlayWindow];
                                 overlayWindow = nil;
                                 
                                 [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                                     if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                                         [window makeKeyWindow];
                                         *stop = YES;
                                     }
                                 }];
                             }
                         }];
    });
}

- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.userInteractionEnabled = YES;
        [overlayWindow makeKeyAndVisible];
    }
    return overlayWindow;
}


@end
