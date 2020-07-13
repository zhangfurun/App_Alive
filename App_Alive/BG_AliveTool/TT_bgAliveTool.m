//
//  TT_bgAliveTool.m
//  App_Alive
//
//  Created by ifenghui on 2020/7/13.
//  Copyright © 2020 ifenghuI. All rights reserved.
//

#import "TT_bgAliveTool.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIApplication.h>

static TT_bgAliveTool *_tool = nil;

@interface TT_bgAliveTool ()
@property (nonatomic, strong) NSURL *audioFileURL;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@end

@implementation TT_bgAliveTool
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tool = [[TT_bgAliveTool alloc] init];
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Silence" ofType:@"wav"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            _tool.audioFileURL = [[NSURL alloc] initFileURLWithPath:filePath];
            [_tool initAudioPlayer];
        }
    });
    return _tool;
}

+ (void)start {
    [[TT_bgAliveTool sharedInstance] start];
}

+ (void)stop {
    [[TT_bgAliveTool sharedInstance] stop];
}

#pragma mark - Methods
- (void)start {
    [self openAudioPlayer];
    [self openBackgroundTask];
}

- (void)stop {
    [self endAudioPlayer];
    [self endBackgroundTask];
}

#pragma mark - AudioPlayer 初始化
- (void)initAudioPlayer {
    [self setupAudioSession];
    [self setupAudioPlayer];
}

- (void)setupAudioSession {
    // 新建AudioSession会话
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    // 设置后台播放
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    if (error) {
        NSLog(@"Error setCategory AVAudioSession: %@", error);
    }
    NSLog(@"%d", audioSession.isOtherAudioPlaying);
    NSError *activeSetError = nil;
    // 启动AudioSession，如果一个前台app正在播放音频则可能会启动失败
    [audioSession setActive:YES error:&activeSetError];
    if (activeSetError) {
        NSLog(@"Error activating AVAudioSession: %@", activeSetError);
    }
}

- (void)setupAudioPlayer {
    //静音文件
    NSURL *fileURL = self.audioFileURL;
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    //静音
    self.audioPlayer.volume = 0;
    //播放一次
    self.audioPlayer.numberOfLoops = 1;
    [self.audioPlayer prepareToPlay];
}

#pragma mark - 开启后台任务
- (void)openBackgroundTask {
    UIApplication *application = [UIApplication sharedApplication];
    
    __weak typeof(self) WS = self;
    __weak UIApplication *weakApplication = application;
    
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        if (WS.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
            [weakApplication endBackgroundTask:WS.backgroundTaskIdentifier];
            WS.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
        
        [WS start];
    }];
}

- (void)endBackgroundTask {
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
}

#pragma mark - 开启音频播放
- (void)openAudioPlayer {
    [self.audioPlayer play];
}

- (void)endAudioPlayer {
    [self.audioPlayer stop];
}
@end
