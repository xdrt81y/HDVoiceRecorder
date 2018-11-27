//
//  HDVoiceRecorderViewController.h
//  HDVoiceRecorder
//
//  Created by haidi han on 2018/11/23.
//  Copyright © 2018 haidi han. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol HDVoiceRecorderDelegate <NSObject>
// 录制了声音，duration为音频时长，单位秒
- (void)voiceRecordSuccess:(NSData*)voiceData withDuration:(NSInteger)duration;
@end


@interface HDVoiceRecorderViewController : UIViewController

@property (nonatomic, weak) id<HDVoiceRecorderDelegate> delegate;

@property (nonatomic, strong) NSData* voiceData;

@end

NS_ASSUME_NONNULL_END
