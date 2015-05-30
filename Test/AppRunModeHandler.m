//
//  AppRunModeHandler.m
//  Test
//
//  Created by whf on 15/5/26.
//  Copyright (c) 2015年 whf. All rights reserved.
//

#import "AppRunModeHandler.h"
#import "AppDelegate.h"
#import <UIKit/UIApplication.h>
#import <AVFoundation/AVFoundation.h>

#if __has_feature(objc_arc)
static AppRunModeHandler * sharedInstace = nil ;

@interface AppRunModeHandler()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) BOOL runOnBackground ;

@end

@implementation AppRunModeHandler

+ (instancetype)sharedInstance
{
    static dispatch_once_t once ;
    dispatch_once(&once, ^{
        sharedInstace = [[[self class] alloc] init];
        
    });
    
    return sharedInstace ;
}

+ (void)load
{
    [AppRunModeHandler sharedInstance];
}

- (id)init
{
    if (self=[super init]) {
        
        self.runOnBackground = YES ;
        [self registerObser];
        [self initializePlayer];
        [self initializeAudioSession];
        
       NSTimer * timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(appIsRunning) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self ;
}

- (void)appIsRunning
{
    NSLog(@"the app is running !!! _player %@ playing",[self isAudioPlaying]?@"is":@"not");
}

- (void)registerObser
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];



}
- (void)unregisterObser
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initializeAudioSession
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                     withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];

    [[AVAudioSession sharedInstance] setActive:YES error:nil];

}

- (void)initializePlayer
{
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"muteAudio" ofType:@"mp3"];
    NSData * audioData = [NSData dataWithContentsOfFile:filePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSLog(@"error the play file not exist");
        return ;
    }
    NSError * error = nil ;
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    if (error) {
        NSLog(@"_audioPlayer init error: %@",error.userInfo);
        return;
    }
    _audioPlayer.volume = 1 ;
    _audioPlayer.numberOfLoops = -1 ;
    if ([_audioPlayer prepareToPlay]) {
        NSLog(@"_audioPlayer prepareToPlay ok");
    }else{
        NSLog(@"_audioPlayer prepareToPlay error");
    }
}

- (void)audioPlay
{
    [_audioPlayer play];
}

- (void)audioPause
{
    [_audioPlayer pause];
}

- (void)audioStop
{
    [_audioPlayer stop];
}

- (BOOL)isAudioPlaying
{
    return _audioPlayer.isPlaying ;
}

- (void)setRuningWhenEnterBackground:(BOOL)isRuning
{
    self.runOnBackground = isRuning ;
    BOOL isPlaying = [self isAudioPlaying];
    if (self.runOnBackground) {
        if (!isPlaying) {
            [self audioPlay];
        }
    }else{
        if (isPlaying) {
            [self audioStop];
        }
    }
}

#pragma application notification 

- (void)applicationDidFinishLaunching:(NSNotification*)notification{}

- (void)applicationDidBecomeActive:(NSNotification*)notification{}

- (void)applicationDidEnterBackground:(NSNotification*)notification
{
    NSLog(@"did enter background");
    UIApplication * application = [notification object];
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        if (self.runOnBackground) {
            [self audioPlay];
        }
    }];
}

- (void)applicationWillEnterForeground:(NSNotification*)notification
{
    NSLog(@"will enter foreground ");
    UIApplication * application = [notification object];
    [application endBackgroundTask:self.backgroundTaskIdentifier];
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid ;
    
    if ([self isAudioPlaying]) {
        [self audioStop];
    }
}

- (void)dealloc
{
    [self unregisterObser];
    
    if ([self isAudioPlaying])
    {
        [self audioStop];
    }
}
@end
#else
#error "should compile in with mode of arc"
#endif