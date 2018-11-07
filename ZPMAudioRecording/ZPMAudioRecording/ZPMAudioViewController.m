//
//  ZPMAudioViewController.m
//  zhaopin
//
//  Created by 吴桐 on 2018/8/17.
//  Copyright © 2018年 zhaopin.com. All rights reserved.
//

#import "ZPMAudioViewController.h"
#import "ZPMAudioBackView.h"
#import "VoiceConverter.h"
#import "ZPMAudioManager.h"
#define __weakSelf  __weak typeof(self) weakSelf = self;
// 屏幕高度
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
// 屏幕宽度
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@interface ZPMAudioViewController ()
@property(strong,nonatomic)ZPMAudioBackView *audioBackView;
@property(strong,nonatomic)ZPMAudioManager *audioManager;
@end

@implementation ZPMAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.audioBackView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ZPMAudioBackView *)audioBackView{
    __weakSelf;
    if (!_audioBackView) {
        _audioBackView = [[ZPMAudioBackView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        //关闭录音页面
        _audioBackView.closeAudioBackView = ^(id sender) {
            [weakSelf.audioManager stopRecord];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
            
        };
        //授权+录音（需要在info.plist中配置授权）
        _audioBackView.startRecord = ^(id sender) {
            [weakSelf.audioManager startRecord];
        };
        //停止录音
        _audioBackView.stopRecord = ^(id sender) {
            [weakSelf.audioManager stopRecord];
        };
        //播放录音
        _audioBackView.playRecord = ^(id sender) {
            [weakSelf.audioManager playRecord];
        };
        //上传语音
        _audioBackView.didFinishAudioInput = ^(id sender) {
            // 初始化对话框
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确认发送语音吗？" preferredStyle:UIAlertControllerStyleAlert];
            // 确定
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                //上传服务器
                [weakSelf.audioManager uploadRecord];
            }];
            UIAlertAction * cancelAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            [alert addAction:okAction];
            [alert addAction:cancelAction];
            
            // 弹出对话框
            [weakSelf presentViewController:alert animated:true completion:nil];
        };
    }
    return _audioBackView;
}

- (ZPMAudioManager *)audioManager{
    if (!_audioManager) {
        __weakSelf;
        _audioManager = [[ZPMAudioManager alloc]init];
        _audioManager.showTime = ^(id sender) {
            int second = [(NSNumber *)sender intValue];
            weakSelf.audioBackView.timeLabel.text = [NSString stringWithFormat:@"00:%02d",second];
        };
        _audioManager.stopPlayRecord = ^(id sender) {
            dispatch_async(dispatch_get_main_queue(), ^{
                int second = [(NSNumber *)sender intValue];
                weakSelf.audioBackView.timeLabel.text = [NSString stringWithFormat:@"00:%02d",second];
                weakSelf.audioBackView.stopBtn.hidden = YES;
                weakSelf.audioBackView.playBtn.hidden = NO;
            });
            
        };
    }
    return _audioManager;
}
@end
