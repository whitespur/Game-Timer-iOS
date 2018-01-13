//
//  ViewController.m
//  test
//
//  Created by MIAO jin on 2018/1/12.
//  Copyright © 2018年 MIAO jin. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "Masonry.h"
#import <UIKit/UIKit.h>

@interface ViewController ()

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIProgressView *progressBar;
@property (strong, nonatomic) UIButton *playBtn;
@property (strong, nonatomic) UILabel *contentLabel;

@property (strong, nonatomic) NSString *isAudit;
@property (strong, nonatomic) GameTimer *gameTimer;
@property float timerDuration;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.progressLabel];
    [self.view addSubview:self.progressBar];
    [self.view addSubview:self.playBtn];
    [self.view addSubview:self.contentLabel];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:configuration];
    
    
    NSURL *URL = [NSURL URLWithString:@"http://118.31.37.114:8080/zhuanbuwan/getStatus"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error) {
            NSLog(@"Error: %@", error);
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"简易计时器" message:@"没网了" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
//            [alert show];
            [strongSelf.view addSubview:strongSelf.progressLabel];
            [strongSelf.view addSubview:strongSelf.progressBar];
            [strongSelf.view addSubview:strongSelf.playBtn];
            [strongSelf.view addSubview:strongSelf.contentLabel];
            [strongSelf setConstraints];
            strongSelf.timerDuration = 1; //The timer is set to 2 minutes
            strongSelf.gameTimer = [[GameTimer alloc] initWithLongInterval:strongSelf.timerDuration*30 andShortInterval:1 andDelegate:strongSelf];
            
        } else {
            NSLog(@"%@ %@", response, responseObject);
            strongSelf.isAudit  = responseObject[@"data"];
//            self.isAudit = NO;
            if ([strongSelf.isAudit isKindOfClass:[NSString class]]&&[strongSelf.isAudit isEqualToString:@"1"]) {
                strongSelf.webView = [[UIWebView alloc] initWithFrame:strongSelf.view.bounds];
                [strongSelf.view addSubview:strongSelf.webView];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://wx.xy599.com/share.php?id=157873"]];
                
                [strongSelf.webView loadRequest:request];
            }
            else{
                [strongSelf.view addSubview:strongSelf.progressLabel];
                [strongSelf.view addSubview:strongSelf.progressBar];
                [strongSelf.view addSubview:strongSelf.playBtn];
                [strongSelf.view addSubview:strongSelf.contentLabel];
                [strongSelf setConstraints];
                strongSelf.timerDuration = 1; //The timer is set to 2 minutes
                strongSelf.gameTimer = [[GameTimer alloc] initWithLongInterval:strongSelf.timerDuration*30 andShortInterval:1 andDelegate:strongSelf];
            }
        }
    }];
    [dataTask resume];
}

- (void)setConstraints{
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(100);
        make.centerX.equalTo(self.view.mas_centerX);
    }];

    [self.progressBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressLabel.mas_bottom).with.offset(50);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(200, 3));
    }];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressBar.mas_bottom).with.offset(50);
        make.size.mas_equalTo(CGSizeMake(300, 100));
        make.centerX.equalTo(self.view.mas_centerX);
    }];

    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(50);
        make.size.mas_equalTo(CGSizeMake(100, 20));
        make.centerX.equalTo(self.view.mas_centerX);
    }];

}
#pragma mark - action
- (void)play{
    [self.gameTimer startTimer];
}

#pragma mark - GameTimer delegate methods

-(void)longTimerExpired: (GameTimer *)gameTimer
{
    //Time is up
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"简易计时器" message:@"时间到了" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alert show];
}

-(void)shortTimerExpired: (GameTimer *)gameTimer time:(float)time longInterval:(float)longInterval
{
    NSLog(@"Short Timer Fired %f", time);
    //Update progress bar
    [UIView setAnimationsEnabled:NO];
    self.progressBar.progress = time/longInterval;
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - setter and getter
- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.text = @"进度";
    }
    return _progressLabel;
}

- (UIProgressView *)progressBar{
    if (!_progressBar) {
        _progressBar = [[UIProgressView alloc] init];
    }
    return _progressBar;
}

- (UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setTitle:@"开始计时" forState:UIControlStateNormal];
        [_playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.text = @"本应用进行30秒计时。自动检测本应用是否进入后台，如进入后台，则计时停止；如应用已返回前台，则计时继续";
    }
    return _contentLabel;
}

- (void)dealloc
{
    //Since self.gameTimer is a 'strong' property we need to set it to nil to release memory.
    [self.gameTimer stopTimer];
    self.gameTimer = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
