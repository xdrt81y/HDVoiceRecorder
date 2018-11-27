//
//  UUAVAudioPlayer.m
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUAVAudioPlayer.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//#import "NetworkService.h"
//#import "NSString+YYAdd.h"
//#import "FileHelper.h"
#import "AVAudioSession+External.h"

@interface UUAVAudioPlayer ()<AVAudioPlayerDelegate>

@property (nonatomic ,strong)  AVAudioPlayer *player;
@property (nonatomic ,assign)  BOOL loading;
@property (nonatomic ,assign)  BOOL isExternalPlaying;

@end

@implementation UUAVAudioPlayer

+ (UUAVAudioPlayer *)sharedInstance
{
    static UUAVAudioPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });    
    return sharedInstance;
}

-(void)playSongWithUrl:(NSString *)songUrl toSave:(NSString *)path
{
    if (!songUrl.length) {
        return;
    }
    
    [self.delegate UUAVAudioPlayerBeiginLoadVoice];
    self.loading = YES;
    
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* errMsg;
        // 如果文件不存在，则下载
        // 此处需要实现网络下载音频文件
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            //errMsg = [NetworkService downloadFile:songUrl toPath:path autoUnzip:NO cacheThumb:nil progressBlock:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (wSelf.delegate && [wSelf.delegate respondsToSelector:@selector(UUAVAudioPlayerDidLoadedVoice)]) {
                [wSelf.delegate UUAVAudioPlayerDidLoadedVoice];
            }
            if (!errMsg) {
                [wSelf playSongWithUrl:[NSURL fileURLWithPath:path]];
            }
            wSelf.loading = NO;
        });
        
    });
}

-(void)playSongWithData:(NSData *)songData
{
    [self setupPlaySound];
    [self playSoundWithData:songData];
}

-(void) playSongWithUrl:(NSURL *)url
{
    if (!url.isFileURL) {
//        NSString* webPath = [self webFilePathForFile:[url.absoluteString.md5String stringByAppendingString:@".mp3"]];
//        [self playSongWithUrl:url.absoluteString toSave:webPath];
        return;
    }
    
    [self setupPlaySound];
    if (_player) {
        [_player stop];
        _player.delegate = nil;
        _player = nil;
    }
    NSError *playerError;
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&playerError];
    _player.volume = 1.0f;
    if (_player == nil){
        NSLog(@"ERror creating player: %@", [playerError description]);
        return;
    }
    _player.delegate = self;
    [_player play];
    [self.delegate UUAVAudioPlayerBeiginPlay];
}
-(void)playSoundWithData:(NSData *)soundData {
    if (_player) {
        [_player stop];
        _player.delegate = nil;
        _player = nil;
    }
    
    NSError *playerError;
    _player = [[AVAudioPlayer alloc]initWithData:soundData error:&playerError];
    _player.volume = 1.0f;
    if (_player == nil){
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    _player.delegate = self;
    [_player play];
    if (self.delegate && [self.delegate respondsToSelector:@selector(UUAVAudioPlayerBeiginPlay)]) {
        [self.delegate UUAVAudioPlayerBeiginPlay];
    }

}

-(void)setupPlaySound{
    self.isExternalPlaying = [AVAudioSession isExternalAudioPlaying];
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(UUAVAudioPlayerDidFinishPlay)]) {
        [self.delegate UUAVAudioPlayerDidFinishPlay];
    }
    if (self.isExternalPlaying) {
        [AVAudioSession recoverExternalPlaying];
    }
}

- (void)stopSound
{
    if (_player && _player.isPlaying) {
        [_player stop];
    }
    if (self.isExternalPlaying) {
        [AVAudioSession recoverExternalPlaying];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
    if (self.delegate && [self.delegate respondsToSelector:@selector(UUAVAudioPlayerDidFinishPlay)]) {
        [self.delegate UUAVAudioPlayerDidFinishPlay];
    }
}

- (BOOL)isPlaying {
    if (self.loading) {
        return YES;
    }
    return _player.isPlaying;
}

#pragma mark 本地文件操作
// 下载的音频文件的路径名
- (NSString*)webFilePathForFile:(NSString*)fileName {
    NSString* cachesDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    NSString* webFilesDir = [cachesDir stringByAppendingPathComponent:@"WebFiles"];
    [self ensureCreateDir:webFilesDir];
    return [webFilesDir stringByAppendingPathComponent:fileName];
}

// 确保创建文件夹
- (void)ensureCreateDir:(NSString*)dir {
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dir]) {
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end
