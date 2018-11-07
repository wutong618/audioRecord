//
//  ViewController.m
//  ZPMAudioRecording
//
//  Created by 吴桐 on 2018/11/6.
//  Copyright © 2018年 cowlevel. All rights reserved.
//

#import "ViewController.h"
#import "ZPMAudioViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 200, 50);
    btn.center = self.view.center;
    btn.backgroundColor = [UIColor blackColor];
    [btn setTitle:@"进入录音页面" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(gotoAudioVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)gotoAudioVC{
    ZPMAudioViewController *audioVC = [[ZPMAudioViewController alloc]init];
    [self presentViewController:audioVC animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
