//
//  HDVoiceProgressHUD.h
//  HDVoiceRecorder
//
//  Created by haidi han on 2018/11/23.
//  Copyright © 2018 haidi han. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDVoiceProgressHUD : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

+ (void)show;
+ (void)dismissWithSuccess:(NSString *)str;
+ (void)dismissWithError:(NSString *)str;
+ (void)changeSubTitle:(NSString *)str;

@end
