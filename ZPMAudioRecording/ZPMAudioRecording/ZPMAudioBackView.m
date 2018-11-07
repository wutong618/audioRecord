//
//  ZPMAudioBackView.m
//  RLAudioRecord
//
//  Created by 吴桐 on 2018/8/15.
//  Copyright © 2018年 Enorth.com. All rights reserved.
//

#import "ZPMAudioBackView.h"
#import "SDAutoLayout.h"
#import "ZPMAudioManager.h"

@interface ZPMAudioBackView()
@property(strong,nonatomic)UIButton *closeBtn;//关闭当前页面
@property(strong,nonatomic)UILabel *titleLabel;//标题
@property(strong,nonatomic)UILabel *reRecordLabel;//重新录制
@property(strong,nonatomic)UILabel *uploadRecordLabel;//上传
@property(strong,nonatomic)NSString *recordFinishTime;//录音完毕时长
@end

@implementation ZPMAudioBackView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

#pragma mark - UI布局
- (void)setUI{
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.closeBtn];
    [self addSubview:self.titleLabel];
    [self addSubview:self.recordBtn];
    [self addSubview:self.playBtn];
    [self addSubview:self.stopBtn];
    [self addSubview:self.reRecordLabel];
    [self addSubview:self.uploadRecordLabel];
    [self addSubview:self.timeLabel];
    
    [self setLayout];
}

- (void)setLayout{
    self.closeBtn.sd_layout
    .rightSpaceToView(self, 26)
    .topSpaceToView(self, 34.5)
    .widthIs(16)
    .heightIs(16);
    
    self.titleLabel.sd_layout
    .centerXEqualToView(self)
    .topSpaceToView(self, 98)
    .autoHeightRatio(0);
    [self.titleLabel setSingleLineAutoResizeWithMaxWidth:[UIScreen mainScreen].bounds.size.width - 64];
    
    self.recordBtn.sd_layout
    .centerXEqualToView(self)
    .bottomSpaceToView(self, 164)
    .widthIs(90)
    .heightIs(90);
    
    self.playBtn.sd_layout
    .topSpaceToView(self, self.height/2)
    .centerXEqualToView(self)
    .widthIs(90)
    .heightIs(90);
    
    self.stopBtn.sd_layout
    .leftEqualToView(self.recordBtn)
    .topEqualToView(self.recordBtn)
    .widthIs(90)
    .heightIs(90);
    
    self.reRecordLabel.sd_layout
    .leftSpaceToView(self, 68)
    .bottomSpaceToView(self, 40)
    .autoHeightRatio(0);
    [self.reRecordLabel setSingleLineAutoResizeWithMaxWidth:100];
    
    self.uploadRecordLabel.sd_layout
    .rightSpaceToView(self, 68)
    .bottomSpaceToView(self, 40)
    .autoHeightRatio(0);
    [self.uploadRecordLabel setSingleLineAutoResizeWithMaxWidth:100];
    
    self.timeLabel.sd_layout
    .centerXEqualToView(self)
    .centerYEqualToView(self)
    .heightIs(45)
    .widthIs(180);
}

#pragma mark - 录音播放核心方法
- (void)startRecording{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.startRecord){
            self.startRecord(nil);
        }
        //点击录音时，改变视图布局
        [self updateViewWhenStartRecord];
    });
}

- (void)stopRecording{
    if(self.stopRecord){
        self.stopRecord(nil);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //点击停止时，改变视图布局
        [self updateViewWhenStopRecord];
    });
    
}

- (void)playRecording{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.playRecord){
            self.playRecord(nil);
        }
        self.stopBtn.hidden = NO;
        self.playBtn.hidden = YES;
    });
}

#pragma mark - 自定义方法
//录音
-(void)reRecord{
    self.reRecordLabel.hidden = YES;
    self.uploadRecordLabel.hidden = YES;
    self.timeLabel.hidden = YES;
    self.stopBtn.hidden = YES;
    self.playBtn.hidden = YES;
    self.recordBtn.hidden = NO;
    self.titleLabel.text = @"你可以这样说...";
    self.timeLabel.text = @"00:00";
    
    self.stopBtn.sd_resetNewLayout
    .leftEqualToView(self.recordBtn)
    .topEqualToView(self.recordBtn)
    .widthIs(90)
    .heightIs(90);
    
    self.timeLabel.sd_resetNewLayout
    .centerYEqualToView(self)
    .centerXEqualToView(self)
    .widthIs(180)
    .heightIs(45);
}

-(void)uploadRecordData{
    NSLog(@"上传录音数据");
    if(self.didFinishAudioInput){
        self.didFinishAudioInput(nil);
    }
}

-(void)updateViewWhenStopRecord{
    self.stopBtn.hidden = YES;
    self.playBtn.hidden = NO;
    self.titleLabel.text = @"录制完毕";
    self.reRecordLabel.hidden = NO;
    self.uploadRecordLabel.hidden = NO;
    self.recordFinishTime = self.timeLabel.text;
    
    self.stopBtn.sd_resetNewLayout
    .topSpaceToView(self, self.height/2)
    .centerXEqualToView(self)
    .widthIs(90)
    .heightIs(90);
    
    self.timeLabel.sd_layout
    .bottomSpaceToView(self.stopBtn, 24)
    .centerXEqualToView(self)
    .widthIs(180)
    .heightIs(45);
    [self.timeLabel updateLayout];
}

-(void)updateViewWhenStartRecord{
    self.stopBtn.hidden = NO;
    self.recordBtn.hidden = YES;
    self.titleLabel.text = @"录制中...";
    self.timeLabel.hidden = NO;
}

- (void)closeCurrentPage{
    if(self.closeAudioBackView){
        self.closeAudioBackView(nil);
    }
}

#pragma mark - 懒加载
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightRegular];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.text = @"你可以这样说...";
    }
    return _titleLabel;
}

- (UILabel *)reRecordLabel{
    if (!_reRecordLabel) {
        _reRecordLabel = [[UILabel alloc]init];
        _reRecordLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _reRecordLabel.textColor = [UIColor blackColor];
        _reRecordLabel.backgroundColor = [UIColor whiteColor];
        _reRecordLabel.userInteractionEnabled = YES;
        _reRecordLabel.text = @"重新录制";
        UITapGestureRecognizer *recordGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reRecord)];
        [_reRecordLabel addGestureRecognizer:recordGes];
        _reRecordLabel.hidden = YES;
    }
    return _reRecordLabel;
}

- (UILabel *)uploadRecordLabel{
    if (!_uploadRecordLabel) {
        _uploadRecordLabel = [[UILabel alloc]init];
        _uploadRecordLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        _uploadRecordLabel.textColor = [UIColor blueColor];
        _uploadRecordLabel.backgroundColor = [UIColor whiteColor];
        _uploadRecordLabel.text = @"提交";
        _uploadRecordLabel.hidden = YES;
        _uploadRecordLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *uploadGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(uploadRecordData)];
        [_uploadRecordLabel addGestureRecognizer:uploadGes];
    }
    return _uploadRecordLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.font = [UIFont systemFontOfSize:50 weight:UIFontWeightLight];
        _timeLabel.textColor = [UIColor blueColor];
        _timeLabel.backgroundColor = [UIColor whiteColor];
        _timeLabel.text = @"00:00";
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.hidden = YES;
    }
    return _timeLabel;
}


- (UIButton *)recordBtn{
    if (!_recordBtn) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordBtn.layer.masksToBounds = YES;
        _recordBtn.layer.cornerRadius = 45;
        _recordBtn.backgroundColor = [UIColor blueColor];
        [_recordBtn setBackgroundImage:[UIImage imageNamed:@"ic_record"] forState:UIControlStateNormal];
        [_recordBtn addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordBtn;
}

- (UIButton *)stopBtn{
    if (!_stopBtn) {
        _stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stopBtn.backgroundColor = [UIColor blueColor];
        _stopBtn.layer.masksToBounds = YES;
        _stopBtn.layer.cornerRadius = 45;
        [_stopBtn setBackgroundImage:[UIImage imageNamed:@"ic_stop"] forState:UIControlStateNormal];
        [_stopBtn setHidden:YES];
        [_stopBtn addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopBtn;
}

- (UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"ic_play"] forState:UIControlStateNormal];
        _playBtn.backgroundColor = [UIColor greenColor];
        _playBtn.layer.masksToBounds = YES;
        _playBtn.layer.cornerRadius = 45;
        [_playBtn setHidden:YES];
        [_playBtn addTarget:self action:@selector(playRecording) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
        _closeBtn.backgroundColor = [UIColor whiteColor];
        [_closeBtn addTarget:self action:@selector(closeCurrentPage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(void)dealloc{
    NSLog(@"dealloc succ");
}

@end
