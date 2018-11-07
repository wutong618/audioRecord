//
//  ZPMAudioBackView.h
//  RLAudioRecord
//
//  Created by 吴桐 on 2018/8/15.
//  Copyright © 2018年 Enorth.com. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^EventHandler)(id sender);

@interface ZPMAudioBackView : UIView

@property(strong,nonatomic)NSString *fileName;
@property(strong,nonatomic)UILabel *timeLabel;//计时器
@property(strong,nonatomic)UIButton *recordBtn;//录制
@property(strong,nonatomic)UIButton *stopBtn;//停止
@property(strong,nonatomic)UIButton *playBtn;//播放
//关闭当前页面
@property(strong,nonatomic)EventHandler closeAudioBackView;
//授权并录音
@property(strong,nonatomic)EventHandler startRecord;
//停止录音
@property(strong,nonatomic)EventHandler stopRecord;
//播放语音
@property(strong,nonatomic)EventHandler playRecord;
//上传语音
@property(strong,nonatomic)EventHandler didFinishAudioInput;

@end
