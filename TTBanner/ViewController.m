//
//  ViewController.m
//  TTBanner
//
//  Created by wangd on 2018/3/11.
//  Copyright © 2018年 wangd. All rights reserved.
//

#import "ViewController.h"
#import "TTBanner.h"

#define TT_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define TT_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController () <TTBannerDataSource, TTBannerDelegate>

@property (nonatomic, copy) NSArray *bannerArr;
@property (nonatomic, strong) TTBanner *banner;

@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.view addSubview:self.banner];
}

#pragma mark - TTBannerDataSource

- (NSInteger)numberOfItemsInBanner:(TTBanner *)banner {
    
    return self.bannerArr.count;
}

- (UIView *)banner:(TTBanner *)banner viewForItemAtIndex:(NSInteger)index {
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.bannerArr[index]]];
    
    return imgView;
}

#pragma mark - TTBannerDelegate

- (void)banner:(TTBanner *)banner didSelectAtIndex:(NSInteger)index {
    
    NSLog(@"图片 -- %@ -- 被点击, index = %ld", self.bannerArr[index], (long)index);
}

#pragma mark - Event Response

- (IBAction)shouldAutoScroll:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    self.banner.autoScroll = !sender.selected;
}

- (IBAction)bannerPlay:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.banner suspendAutoScroll];
    }else {
        [self.banner resumeAutoScroll];
    }
}


#pragma mark - Getter

- (NSArray *)bannerArr {
    
    if (!_bannerArr) {
        _bannerArr = @[@"banner_1", @"banner_2", @"banner_3", @"banner_4"];
//        _bannerArr = @[@"banner_1"];
    }
    
    return _bannerArr;
}

- (TTBanner *)banner {
    
    if (!_banner) {
        _banner = [[TTBanner alloc] initWithFrame:CGRectMake(0, 0, TT_SCREEN_WIDTH, 220.0)];
        _banner.backgroundColor = [UIColor whiteColor];
        _banner.dataSource = self;
        _banner.delegate = self;
//        _banner.shouldLoop = NO;
    }
    
    return _banner;
}

@end
