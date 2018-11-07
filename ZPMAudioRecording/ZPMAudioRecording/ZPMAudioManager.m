//
//  ZPMAudioManager.m
//  RLAudioRecord
//
//  Created by 吴桐 on 2018/8/14.
//  Copyright © 2018年 Enorth.com. All rights reserved.
//

#import "ZPMAudioManager.h"
#import "VoiceConverter.h"
//#import "ZPDAliOssManager.h"
# define COUNTDOWN 60
# define BlockCallWithOneArg(block,arg)  if(block){block(arg);}

@interface ZPMAudioManager () <AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioSession *audioSession;
@property (nonatomic, strong) AVAudioRecorder *recorder;//录音器
@property (nonatomic, strong) AVAudioPlayer *player; //播放器
@property (nonatomic, strong) CADisplayLink *timer; //录音定时器
@property (nonatomic, strong) CADisplayLink *playtimer; //播放定时器
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSURL *recordFileUrl; //文件地址
@end

@implementation ZPMAudioManager
- (instancetype)init{
    self = [super init];
    if (self) {
        self.fileName = @"audioRecordingDemo";
    }
    return self;
}

#pragma mark - 音频核心方法
//获取授权后录音
- (void)startRecord {
    NSLog(@"获取麦克风授权");
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            //用户同意获取麦克风
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self recording];
            });
        }
        else {
            //用户不同意获取麦克风
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                               message:@"需要访问您的麦克风，请在“设置-隐私-麦克风”中允许访问。"
                                                              delegate:self
                                                     cancelButtonTitle:@"确定"
                                                     otherButtonTitles:nil, nil];
                [alert show];
            });
        }
    }];
}

//停止录音
- (void)stopRecord {
    NSLog(@"停止录音");
    if ([_recorder isRecording]) {
        self.lastCount = self.countDown;
        [self.recorder stop];
    }
    else if([_player isPlaying]){
        [self.player stop];
    }
    
    if (_stopPlayRecord) {
        self.stopPlayRecord([NSNumber numberWithInt:self.lastCount]);
    }
    //移除倒计时
    [self removeTimer];
    [self removePlayTimer];
}

//播放录音
- (void)playRecord {
    NSLog(@"播放录音");
    [self.recorder stop];
    if ([self.player isPlaying]){
        return;
    }
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:nil];
    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    //播放计时
    [self addPlayTimer];
    [self.player play];
}

//录音实际方法
- (void)recording{
    self.countDown = 0;
    self.lastCount = 0;
    //启动定时器
    [self addTimer];
    
    //设置为播放和录音状态
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //获取文件路径
    self.recordFileUrl = [NSURL fileURLWithPath:self.filePath];
    
    //开始录音
    if ([self.recorder prepareToRecord]) {
        [self.recorder record];
    }
}

//播放完成
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    BlockCallWithOneArg(self.didfinish, nil);
}

//上传服务器：（需要转化为AMR格式，目的是压缩音频文件大小 & 与安卓保持一致）
- (void)uploadRecord{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *amrPath = [NSString stringWithFormat:@"%@/%@.amr",path,self.fileName];
    //转化为AMR格式
    [VoiceConverter wavToAmr:self.filePath amrSavePath:amrPath];
    
    NSLog(@"上传至阿里云服务器,语音文件路径：%@",amrPath);
    //上传至阿里云服务器
//    [[ZPDAliOssManager sharedInstance]uploadFileByBucketName:@"xxx" andFileName:fileName andFilePath:amrPath succCallBack:^(id result) {
//        NSString *url = result;
//    }];
}

#pragma mark - 定时器相关
//添加录音定时器
- (void)addTimer
{
    self.countDown = 0;
    _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshLabelText)];
    _timer.frameInterval = 60;
    [_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

//添加播放定时器
- (void)addPlayTimer
{
    self.countDown = 0;
    _playtimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshLabelText)];
    _playtimer.frameInterval = 60;
    [_playtimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

//移除录音定时器
- (void)removeTimer
{
    if (_timer) {
        _timer.paused = YES;
        [_timer invalidate];
        _timer = nil;
    }
}

//移除播放定时器
- (void)removePlayTimer
{
    if (_playtimer) {
        _playtimer.paused = YES;
        [_playtimer invalidate];
        _playtimer = nil;
    }
}

//刷新text
-(void)refreshLabelText{
   self.countDown ++;
    if (self.countDown > 60) {
        self.countDown = 60;
    }
    if (self.countDown >self.lastCount && self.lastCount!= 0) {
        [self removePlayTimer];
        dispatch_async(dispatch_get_main_queue(), ^{
            BlockCallWithOneArg(self.stopPlayRecord, [NSNumber numberWithInt:self.lastCount]);
        });
        
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            BlockCallWithOneArg(self.showTime, [NSNumber numberWithInt:self.countDown]);
        });
    }
}

#pragma mark - 懒加载
- (AVAudioSession *)audioSession{
    if(!_audioSession){
        _audioSession =[AVAudioSession sharedInstance];
        [_audioSession setActive:YES error:nil];
    }
    return _audioSession;
}

- (NSString *)filePath{
    if (!_filePath) {
        //获取沙盒地址
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        _filePath = [NSString stringWithFormat:@"%@/%@.wav",path,_fileName];
    }
    return _filePath;
}

- (AVAudioRecorder *)recorder{
    if (!_recorder) {
        //设置参数
        NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                       [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                       // 音频格式
                                       [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                       //采样位数  8、16、24、32 默认为16
                                       [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                       // 音频通道数 1 或 2
                                       [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                       //录音质量
                                       [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                       nil];
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:recordSetting error:nil];
    }
    return _recorder;
}

@end
