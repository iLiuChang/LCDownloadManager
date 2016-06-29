//
//  ViewController.m
//  LCDownloadDemo
//
//  Created by LiuChang on 16-6-24.
//  Copyright (c) 2016年 LiuChang. All rights reserved.
//

#import "ViewController.h"
#import "LCDownloadManager.h"

static const NSUInteger Tag1 = 1000;
static const NSUInteger Tag2 = 1001;
@interface ViewController ()
{
    UILabel *_button1;
    UILabel *_button2;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LCDownloadManager *lc_D = [[LCDownloadManager alloc]init];
    UIButton *button1 = [[UIButton alloc]init];
    button1.backgroundColor = [UIColor redColor];
    button1.frame = CGRectMake(30, 30, 100, 30);
    [button1 setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];

    [button1 addTarget:self action:@selector(click1:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button1];
    
    UIButton *rBtn = [[UIButton alloc]init];
    rBtn.backgroundColor = [UIColor orangeColor];
    rBtn.frame = CGRectMake(260, 30, 50, 30);
    [rBtn setTitle:@"删除" forState:(UIControlStateNormal)];
    [self.view addSubview:rBtn];
    [rBtn addTarget:self action:@selector(remove1:) forControlEvents:(UIControlEventTouchUpInside)];
    
    UILabel *label1 = [[UILabel alloc]init];
    label1.frame = CGRectMake(150, 30, 100, 30);
    label1.backgroundColor = [UIColor yellowColor];
    label1.textColor = [UIColor blackColor];
    label1.text = [self getText:[lc_D progressValue:Tag1]];
    [self.view addSubview:label1];
    _button1 = label1;
    UIButton *button2 = [[UIButton alloc]init];
    button2.backgroundColor = [UIColor redColor];
    button2.frame = CGRectMake(30, 100, 100, 30);
    [button2 setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [button2 addTarget:self action:@selector(click2:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button2];
    
    UILabel *label2 = [[UILabel alloc]init];
    label2.frame = CGRectMake(150, 100, 100, 30);
    label2.backgroundColor = [UIColor yellowColor];
    label2.textColor = [UIColor blackColor];
    label2.text = [self getText:[lc_D progressValue:Tag2]];
    [self.view addSubview:label2];
    _button2 = label2;
    
    UIButton *rBtn2 = [[UIButton alloc]init];
    rBtn2.backgroundColor = [UIColor orangeColor];
    rBtn2.frame = CGRectMake(CGRectGetMaxX(label2.frame) + 10, 100, 50, 30);
    [rBtn2 setTitle:@"删除" forState:(UIControlStateNormal)];
    [self.view addSubview:rBtn2];
    [rBtn2 addTarget:self action:@selector(remove2:) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *rBtn3 = [[UIButton alloc]init];
    rBtn3.backgroundColor = [UIColor orangeColor];
    rBtn3.frame = CGRectMake(CGRectGetMaxX(label2.frame) + 10, 200, 50, 30);
    [rBtn3 setTitle:@"清空" forState:(UIControlStateNormal)];
    [self.view addSubview:rBtn3];
    [rBtn3 addTarget:self action:@selector(removeAll:) forControlEvents:(UIControlEventTouchUpInside)];
}
- (NSString *)getText:(CGFloat)progress {
    NSString *scaleStr = [NSString stringWithFormat:@"%.2f",progress];
    return scaleStr;
}

- (void)removeAll:(UIButton *)button {
    [[LCDownloadManager sharedInstance] removeAllFileData];
}

- (void)click1:(UIButton *)button {
    [[LCDownloadManager sharedInstance] downloadData:@"http://baobab.wdjcdn.com/1455782903700jy.mp4" WithTag:Tag1 progress:^(CGFloat progress) {
     
        dispatch_async(dispatch_get_main_queue(), ^{
            _button1.text = [self getText:progress];

        });
    }state:nil];
}

- (void)click2:(UIButton *)button {
    [[LCDownloadManager sharedInstance] downloadData:@"http://baobab.wdjcdn.com/1455782903700jy.mp4" WithTag:Tag2 progress:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _button2.text = [self getText:progress];
            
        });
    }state:^(LCDownloadState state) {
        NSLog(@"%d",state);
    }];
}

- (void)remove1:(UIButton *)button {
    [[LCDownloadManager sharedInstance] removeFileData:Tag1];
}
-(void)remove2:(UIButton *)button {
    [[LCDownloadManager sharedInstance] removeFileData:Tag2];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
