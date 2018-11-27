//
//  HDVoiceRecorderViewController.m
//  HDVoiceRecorder
//
//  Created by haidi han on 2018/11/23.
//  Copyright © 2018 haidi han. All rights reserved.
//

#import "HDVoiceRecorderViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HDVoiceButton.h"
#import "Mp3Recorder.h"
#import "HDVoiceProgressHUD.h"

@interface HDVoiceRecorderViewController () <Mp3RecorderDelegate>

@property (nonatomic, strong) Mp3Recorder* mp3Recoder;
@property (nonatomic, assign) NSInteger    recordTime;
@property (nonatomic, strong) NSTimer*     recordTimer;

@property (nonatomic, strong) HDVoiceButton* voiceBtn;
@property (nonatomic, strong) UIButton* recordBtn;

@end

@implementation HDVoiceRecorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"录音";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.mp3Recoder = [[Mp3Recorder alloc] initWithDelegate:self];
    
    [self initView];
}

- (void)initView {
    CGFloat viewW = self.view.frame.size.width;
    CGFloat viewH = self.view.frame.size.height;
    //获取图片资源
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:[mainBundle pathForResource:@"HDVoiceRecorder" ofType:@"bundle"]];
    
    UIButton* recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recordBtn.frame = CGRectMake(40, viewH-50-44, viewW-40*2, 44);
    [recordBtn setBackgroundImage:[UIImage imageNamed:@"chat_message_back" inBundle:resourcesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [recordBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [recordBtn setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [recordBtn setTitle:@" 按住 说话" forState:UIControlStateNormal];
    [recordBtn setTitle:@" 松开 完成" forState:UIControlStateHighlighted];
    [recordBtn setImage:[UIImage imageNamed:@"talk" inBundle:resourcesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [recordBtn addTarget:self action:@selector(beginRecordVoice) forControlEvents:UIControlEventTouchDown];
    [recordBtn addTarget:self action:@selector(endRecordVoice) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [recordBtn addTarget:self action:@selector(remindDragExit) forControlEvents:UIControlEventTouchDragExit];
    [recordBtn addTarget:self action:@selector(remindDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    [self.view addSubview:recordBtn];
    self.recordBtn = recordBtn;
    
    HDVoiceButton* voiceBtn = [[HDVoiceButton alloc] initWithStyle:VPStyleDark];
    voiceBtn.frame = CGRectMake(0, 0, 30, 30);
    voiceBtn.center = self.view.center;
    voiceBtn.hidden = !self.voiceData;
    [voiceBtn addTarget:self action:@selector(playVoice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:voiceBtn];
    self.voiceBtn = voiceBtn;
}

- (void)done {
    if (self.delegate && self.voiceData) {
        [self.delegate voiceRecordSuccess:self.voiceData withDuration:self.recordTime+1];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playVoice {
    if (!self.voiceBtn.isPlaying) {
        [self.voiceBtn playData:self.voiceData];
    }
}

- (void)beginRecordVoice {
    NSString *mediaType = AVMediaTypeAudio;// Or AVMediaTypeAudio
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法使用麦克风" message:@"请在iPhone的“设置－隐私－麦克风”中允许访问麦克风。" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        [self.mp3Recoder startRecord];
        self.recordTime = 0;
        self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countVoiceTime) userInfo:nil repeats:YES];
        [HDVoiceProgressHUD show];
    }
}

- (void)endRecordVoice {
    if (self.recordTimer) {
        [self.mp3Recoder stopRecord];
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
}

- (void)cancelRecordVoice {
    if (self.recordTimer) {
        [self.mp3Recoder cancelRecord];
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    [HDVoiceProgressHUD dismissWithError:@"取消"];
}

- (void)remindDragExit {
    [HDVoiceProgressHUD changeSubTitle:@"松开手指，取消录音"];
}

- (void)remindDragEnter {
    [HDVoiceProgressHUD changeSubTitle:@"手指上滑，取消录音"];
}

- (void)countVoiceTime {
    self.recordTime ++;
    if (self.recordTime >= 60) {
        [self endRecordVoice];
    }
}

#pragma mark - Mp3RecorderDelegate

- (void)beginConvert {
}

//回调录音资料
- (void)endConvertWithData:(NSData *)voiceData {
    [HDVoiceProgressHUD dismissWithSuccess:@"录音成功"];
    
    //缓冲消失时间 (最好有block回调消失完成)
    self.recordBtn.enabled = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.voiceData = voiceData;
        weakSelf.recordBtn.enabled = YES;
        weakSelf.voiceBtn.hidden = NO;
        
        weakSelf.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:weakSelf action:@selector(done)];
    });
}

- (void)failRecord {
    [HDVoiceProgressHUD dismissWithSuccess:@"录音太短"];
    
    //缓冲消失时间 (最好有block回调消失完成)
    self.recordBtn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.recordBtn.enabled = YES;
    });
}

@end
