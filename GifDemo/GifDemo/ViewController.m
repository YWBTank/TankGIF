//
//  ViewController.m
//  GifDemo
//
//  Created by yanwb on 16/3/31.
//  Copyright © 2016年 wbyan. All rights reserved.
//

#import "ViewController.h"
#import "TankGifView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *path = @"http://hd.shijue.cvidea.cn/tf/130426/2278315/52adbea43dfae9b54d000003.GIF";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@".GIF"];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"1寸" ofType:@".jpg"];
    
    TankGifView *tankGifView = [[TankGifView alloc] initWithCenter:CGPointMake(100, 100) file:path];
    [self.view addSubview:tankGifView];
    [tankGifView startGif];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
