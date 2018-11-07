//
//  ZPMAudioManager.h
//  RLAudioRecord
//
//  Created by 吴桐 on 2018/8/14.
//  Copyright © 2018年 Enorth.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ZPMAudioBackView.h"

@interface ZPMAudioManager : NSObject

@property (nonatomic, strong) EventHandler showTime;//显示时间
@property (nonatomic, strong) EventHandler stopPlayRecord;//停止播放
@property (nonatomic, strong) EventHandler didfinish;//播放finish
@property (assign,nonatomic)  int countDown;  //倒计时
@property (assign,nonatomic)  int lastCount;

//获取授权并录制
- (void)startRecord;
//停止录制
- (void)stopRecord;
//播放
- (void)playRecord;
//上传服务器
- (void)uploadRecord;

@end
