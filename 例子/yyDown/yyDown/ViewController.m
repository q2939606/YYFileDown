//
//  ViewController.m
//  yyDown
//
//  Created by mac on 15/7/24.
//  Copyright (c) 2015年 yy. All rights reserved.
//

#import "ViewController.h"
#import "YYFileDown/YYDownFile.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

/** 用来暂停 */
@property (nonatomic,strong) YYDownFile * downFile;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)begin:(id)sender {
    
   self.downFile =  [YYDownFile DowFileWith:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4" downing:^(double progress) {
        NSLog(@"正在下载%f",progress);
        self.progressView.progress = progress /100.0;
        
    } completionHandler:^(NSError *error, NSString *filePath) {
        NSLog(@"结束了%@",error);
    }];
    
}

- (IBAction)ka:(id)sender {
    [self.downFile pause];
}

@end
