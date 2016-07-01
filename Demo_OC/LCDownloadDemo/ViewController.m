//
//  ViewController.m
//  LCDownloadDemo
//
//  Created by LiuChang on 16-6-24.
//  Copyright (c) 2016年 LiuChang. All rights reserved.
//

#import "ViewController.h"
#import "LCDownloadManager.h"

static const NSUInteger Tag1 = 10;
static const NSUInteger Tag2 = 1007;
NSString *URL = @"http://baobab.wdjcdn.com/1455782903700jy.mp4";
@interface ViewController ()
{
    UILabel *_label1;
    UILabel *_label2;
    UIButton *_button1;
    UIButton *_button2;
    UIProgressView *_pv1;
    UIProgressView *_pv2;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LCDownloadManager *lc_D = [[LCDownloadManager alloc]init];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 50, 50)];
    label1.text = [NSString stringWithFormat:@"%.2f",[lc_D progressWithTag:Tag1]];
    label1.textColor = [UIColor blackColor];
    [self.view addSubview:label1];
    _label1 = label1;
    UIProgressView *pv1 = [[UIProgressView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame), 50, 200, 30)];
    pv1.progressTintColor = [UIColor blueColor];
    pv1.progress = [lc_D progressWithTag:Tag1];
    [self.view addSubview:pv1];
    _pv1 = pv1;
    UIButton *button1 = [[UIButton alloc]init];
    button1.frame = CGRectMake(CGRectGetMaxX(pv1.frame), 30, 50, 50);
    [button1 setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [button1 setImage:[UIImage imageNamed:@"pauce"] forState:UIControlStateSelected];
    [button1 addTarget:self action:@selector(click1:) forControlEvents:(UIControlEventTouchUpInside)];
    _button1 = button1;
    [self.view addSubview:button1];
    
    UIButton *rBtn = [[UIButton alloc]init];
    rBtn.frame = CGRectMake(CGRectGetMaxX(button1.frame), 30, 50, 50);
    [rBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [self.view addSubview:rBtn];
    [rBtn addTarget:self action:@selector(remove1:) forControlEvents:(UIControlEventTouchUpInside)];
    
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 50, 50)];
    label2.text = [NSString stringWithFormat:@"%.2f",[lc_D progressWithTag:Tag2]];
    label2.textColor = [UIColor blackColor];
    [self.view addSubview:label2];
    _label2 = label2;
    UIProgressView *pv2 = [[UIProgressView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(label1.frame), 120, 200, 30)];
    pv2.progressTintColor = [UIColor blueColor];
    pv2.progress = [lc_D progressWithTag:Tag2];
    [self.view addSubview:pv2];
    _pv2= pv2;
    UIButton *button2 = [[UIButton alloc]init];
    button2.frame = CGRectMake(CGRectGetMaxX(pv2.frame), 100, 50, 50);
    [button2 setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [button2 setImage:[UIImage imageNamed:@"pauce"] forState:UIControlStateSelected];
    [button2 addTarget:self action:@selector(click2:) forControlEvents:(UIControlEventTouchUpInside)];
    _button2 = button2;
    [self.view addSubview:button2];
    
    UIButton *rBtn2 = [[UIButton alloc]init];
    rBtn2.frame = CGRectMake(CGRectGetMaxX(button2.frame), 100, 50, 50);
    [rBtn2 setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [self.view addSubview:rBtn2];
    [rBtn2 addTarget:self action:@selector(remove2:) forControlEvents:(UIControlEventTouchUpInside)];
   
    
    UIButton *rBtn3 = [[UIButton alloc]init];
    rBtn3.backgroundColor = [UIColor orangeColor];
    rBtn3.frame = CGRectMake(200, 200, 50, 30);
    [rBtn3 setTitle:@"清空" forState:(UIControlStateNormal)];
    [self.view addSubview:rBtn3];
    [rBtn3 addTarget:self action:@selector(removeAll:) forControlEvents:(UIControlEventTouchUpInside)];
}
- (NSString *)getText:(CGFloat)progress {
    NSString *scaleStr = [NSString stringWithFormat:@"%.2f",progress];
    return scaleStr;
}

- (void)removeAll:(UIButton *)button {
    _label1.text = @"0.00";
    _pv1.progress = 0;
    _label2.text = @"0.00";
    _pv2.progress = 0;
    _button1.selected = NO;
    _button2.selected = NO;
    [[LCDownloadManager sharedInstance] removeAllFileData];
}

- (void)click1:(UIButton *)button {
    button.selected = !button.selected;
    [[LCDownloadManager sharedInstance] downloadDataWithURL:URL tag:Tag1 resume:button.selected progress:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _label1.text = [self getText:progress];
            _pv1.progress = progress;
            
        });
    } state:nil];

}

- (void)click2:(UIButton *)button {
    button.selected = !button.selected;
    [[LCDownloadManager sharedInstance] downloadDataWithURL:URL tag:Tag2 resume:button.selected progress:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _label2.text = [self getText:progress];
            _pv2.progress = progress;
            
        });
    } state:nil];

}

- (void)remove1:(UIButton *)button {
    _label1.text = @"0.00";
    _pv1.progress = 0;
    _button1.selected = NO;
    [[LCDownloadManager sharedInstance] removeFileDataWithTag:Tag1];
}
-(void)remove2:(UIButton *)button {
    _label2.text = @"0.00";
    _pv2.progress = 0;
    _button2.selected = NO;
    [[LCDownloadManager sharedInstance] removeFileDataWithTag:Tag2];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
